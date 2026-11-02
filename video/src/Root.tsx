import { MyComposition } from "./Composition";
import { ChallengeComposition } from "./ChallengeFilm";
import { JudgesComposition } from "./JudgesFilm";

export const RemotionRoot: React.FC = () => {
  return (
    <>
      <MyComposition />
      <ChallengeComposition />
      <JudgesComposition />
    </>
  );
};
