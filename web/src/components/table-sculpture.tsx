"use client";
import { Component, useEffect, useRef, type ReactNode } from "react";
import { Canvas, useThree } from "@react-three/fiber";
import { useMotionValueEvent, type MotionValue } from "motion/react";
import { Group } from "three";

class SceneBoundary extends Component<
  { children: ReactNode },
  { failed: boolean }
> {
  state = { failed: false };
  static getDerivedStateFromError() {
    return { failed: true };
  }
  render() {
    return this.state.failed ? null : this.props.children;
  }
}
function Ceramic({ progress }: { progress: MotionValue<number> }) {
  const group = useRef<Group>(null);
  const { invalidate, gl } = useThree();
  useMotionValueEvent(progress, "change", (value) => {
    if (group.current) {
      group.current.rotation.z = value * 0.25 - 0.12;
      invalidate();
    }
  });
  useEffect(() => {
    const canvas = gl.domElement;
    const move = (e: PointerEvent) => {
      const r = canvas.getBoundingClientRect();
      if (!group.current) return;
      group.current.rotation.y = ((e.clientX - r.left) / r.width - 0.5) * 0.5;
      group.current.rotation.x =
        0.7 + ((e.clientY - r.top) / r.height - 0.5) * 0.3;
      invalidate();
    };
    const reset = () => {
      if (group.current) {
        group.current.rotation.set(0.7, 0, -0.12);
        invalidate();
      }
    };
    canvas.addEventListener("pointermove", move);
    canvas.addEventListener("pointerleave", reset);
    return () => {
      canvas.removeEventListener("pointermove", move);
      canvas.removeEventListener("pointerleave", reset);
    };
  }, [gl, invalidate]);
  return (
    <group ref={group} rotation={[0.7, 0, -0.12]}>
      <mesh rotation={[-Math.PI / 2, 0, 0]}>
        <cylinderGeometry args={[1.7, 1.5, 0.12, 64]} />
        <meshStandardMaterial color="#eee4c9" roughness={0.28} />
      </mesh>
      <mesh>
        <torusGeometry args={[1.53, 0.14, 12, 64]} />
        <meshStandardMaterial color="#f7efdc" roughness={0.25} />
      </mesh>
      <mesh position={[0, 0, 0.09]}>
        <torusGeometry args={[1.22, 0.018, 8, 64]} />
        <meshStandardMaterial color="#32542c" />
      </mesh>
      {[
        [0, 0.3, 0.35],
        [-0.5, -0.2, 0.34],
        [0.45, -0.35, 0.35],
      ].map((p, i) => (
        <group
          key={i}
          position={p as [number, number, number]}
          rotation={[0, 0, i * 1.7]}
        >
          <mesh scale={[0.36, 0.48, 0.3]}>
            <sphereGeometry args={[1, 32, 24]} />
            <meshStandardMaterial
              color={i === 1 ? "#a1a732" : "#6f7c25"}
              roughness={0.22}
              metalness={0.15}
            />
          </mesh>
          <mesh position={[0, 0.35, 0.16]} scale={[0.07, 0.1, 0.035]}>
            <sphereGeometry args={[1, 12, 12]} />
            <meshStandardMaterial color="#3f481b" />
          </mesh>
        </group>
      ))}
      <mesh
        position={[0.75, 0.55, 0.2]}
        rotation={[0, 0, -0.8]}
        scale={[0.15, 0.55, 0.035]}
      >
        <sphereGeometry args={[1, 24, 16]} />
        <meshStandardMaterial color="#294b2e" roughness={0.8} />
      </mesh>
    </group>
  );
}
export default function TableSculpture({
  progress,
}: {
  progress: MotionValue<number>;
}) {
  return (
    <SceneBoundary>
      <div className="table-canvas">
        <Canvas
          frameloop="demand"
          dpr={[1, 1.5]}
          camera={{ position: [0, 0, 6], fov: 40 }}
          gl={{ antialias: true, alpha: true, powerPreference: "low-power" }}
          fallback={null}
        >
          <ambientLight intensity={2} />
          <directionalLight position={[-3, 4, 5]} intensity={4} />
          <directionalLight position={[3, -2, 2]} intensity={0.7} />
          <Ceramic progress={progress} />
        </Canvas>
      </div>
    </SceneBoundary>
  );
}
