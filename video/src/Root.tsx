import { MyComposition } from "./Composition";
import { ChallengeComposition } from "./ChallengeFilm";
import { JudgesComposition } from "./JudgesFilm";
import { MoneyBrainComposition } from "./motion/MoneyBrain";

export const RemotionRoot: React.FC = () => {
  return (
    <>
      <MyComposition />
      <ChallengeComposition />
      <JudgesComposition />
      <MoneyBrainComposition />
    </>
  );
};
