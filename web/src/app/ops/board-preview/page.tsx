import { notFound } from "next/navigation";
import { BoardPreview } from "./board-preview";
import "../../md-sys.css";
import "../operations.css";
import "@/components/connected/m3/m3.css";
import "../m3-board.css";

/**
 * Development only: the Orders section on an in-memory API, so the board's
 * drag, Undo, code dialog and keyboard path can be tested in a browser
 * without a signed-in café. Commands are recorded on window.__boardCommands.
 */
export default function BoardPreviewPage() {
  if (process.env.NODE_ENV === "production") notFound();
  return <BoardPreview />;
}
