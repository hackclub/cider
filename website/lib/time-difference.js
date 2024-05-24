// Written by ChatGPT

/**
 * Get the time difference between now and a target date
 * @param {Date} targetDate The target date to compare against
 * @returns {string} A human-readable string representing the time difference
 */

export default function getTimeDifferenceText(targetDate) {
  const now = new Date();
  const difference = targetDate - now;

  const minutes = Math.floor((difference / 1000 / 60) % 60);
  const hours = Math.floor((difference / (1000 * 60 * 60)) % 24);
  const days = Math.floor(difference / (1000 * 60 * 60 * 24));

  const timeSegments = [];
  if (days > 0) {
    timeSegments.push(days + " days");
  }
  if (hours > 0) {
    timeSegments.push(hours + " hours");
  }
  if (minutes > 0) {
    timeSegments.push(minutes + " minutes");
  }

  // Add "and" before the last item in the array
  if (timeSegments.length > 1) {
    const lastSegment = timeSegments.pop();
    timeSegments.push("and " + lastSegment);
  }

  return timeSegments.join(", ");
}
