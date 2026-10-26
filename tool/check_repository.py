"""Check tracked public files, without printing possible secret values.

Uses only Python's standard library. This is a repository hygiene check, not a
complete secret scanner, security audit, application test or provider probe.
"""
from pathlib import Path
import re
import subprocess
import sys
from urllib.parse import unquote

ROOT = Path(__file__).resolve().parent.parent


def main():
    raw = subprocess.check_output(['git', 'ls-files', '-z'], cwd=ROOT)
    names = {n for n in raw.decode().split('\0') if n}
    if not names:
        print('No tracked files: stage the reviewed source before running this check.')
        return 1
    errors = []
    patterns = {
        'private key': re.compile(r'-----BEGIN (?:RSA |EC |OPENSSH |ENCRYPTED )?PRIVATE KEY-----'),
        'service account': re.compile(r'"type"\s*:\s*"service_account"'),
        'GitHub token': re.compile(r'(?:gh[pousr]_[A-Za-z0-9]{30,}|github_pat_[A-Za-z0-9_]{50,})'),
        'AWS access key': re.compile(r'\b(?:AKIA|ASIA)[A-Z0-9]{16}\b'),
        'JWT literal': re.compile(r'\beyJ[A-Za-z0-9_-]{20,}\.[A-Za-z0-9_-]{20,}\.[A-Za-z0-9_-]{20,}\b'),
    }
    forbidden = re.compile(r'(^|/)(\.tooling|\.secrets|node_modules|\.dart_tool|\.next|dist|build|qa)(/|$)|(^|/)\.env(?:\.(?!example$).+)?$|/passwords\.yaml$|\.(?:pem|key|p12|pfx|jks|keystore|apk|aab|ipa)$')
    total = 0
    for name in sorted(names):
        path = ROOT / name
        if forbidden.search(name):
            errors.append(f'{name}: forbidden private/generated path')
        if not path.is_file():
            errors.append(f'{name}: tracked file missing')
            continue
        size = path.stat().st_size
        total += size
        if size > 10_000_000:
            errors.append(f'{name}: source asset exceeds 10 MB; review before publication')
        try:
            body = path.read_text(encoding='utf-8')
        except UnicodeError:
            continue
        for label, pattern in patterns.items():
            match = pattern.search(body)
            if match:
                line = body.count('\n', 0, match.start()) + 1
                errors.append(f'{name}:{line}: possible {label}; value suppressed')
        if path.suffix != '.md':
            continue
        for match in re.finditer(r'\[[^\]\n]+\]\(([^)\s]+)\)', body):
            target = unquote(match[1].split('#')[0])
            if not target or ':' in target or target.startswith('//'):
                continue
            destination = (path.parent / target).resolve()
            try:
                relative = destination.relative_to(ROOT).as_posix()
            except ValueError:
                errors.append(f'{name}: link escapes the repository')
                continue
            directory = destination.is_dir() and any(n.startswith(relative.rstrip('/') + '/') for n in names)
            if relative not in names and not directory:
                errors.append(f'{name}: link target is not tracked: {target}')
        for target in re.findall(r'(?:src|href)="([^"]+)"', body):
            if ':' in target or target.startswith('#'):
                continue
            try:
                relative = (path.parent / target).resolve().relative_to(ROOT).as_posix()
            except ValueError:
                errors.append(f'{name}: HTML link escapes the repository')
                continue
            if relative not in names:
                errors.append(f'{name}: HTML asset/link is not tracked: {target}')
    if errors:
        print('\n'.join(errors))
        print(f'FAILED: {len(errors)} issue(s). No matching credential values were printed.')
        return 1
    print(f'PASS: {len(names)} tracked files, {total:,} bytes; local document links, size/path checks and targeted secret patterns.')
    print('This does not establish application functionality or production security.')
    return 0


if __name__ == '__main__':
    sys.exit(main())
