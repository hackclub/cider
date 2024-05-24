import getTimeDifferenceText from "../../lib/time-difference";

export default (_, res) => {
  res
    .status(200)
    .json({ time: getTimeDifferenceText(new Date("2024-06-01T12:00:00")) });
};
