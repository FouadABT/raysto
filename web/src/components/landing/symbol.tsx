/** Isomorphic Material symbol: static page icons remain server-rendered. */
export function Symbol({
  name,
  className = "",
}: {
  name: string;
  className?: string;
}) {
  return (
    <span
      className={`material-symbols-rounded ${className}`}
      aria-hidden="true"
    >
      {name}
    </span>
  );
}
