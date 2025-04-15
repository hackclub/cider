import Airtable from "airtable";

const base = new Airtable({ apiKey: process.env.AIRTABLE_API_KEY }).base(
  process.env.AIRTABLE_BASE_ID
);

export default async function handler(req, res) {
  try {
    const records = await base("Demo Submissions").select({ view: "Granted" }).all();

    const submissions = records.map((record) => ({
      id: record.id,
      name: record.get("App Name"),
      description: record.get("Short Description"),
      author: `${record.get("First Name")} ${record.get("Last Name") || ""}`,
      githubUsername: record.get("GitHub username"),
      slackId: record.get("Hack Club Slack ID"),
      githubUrl: record.get("Code URL (URL to GitHub / other code host repo)"),
      testflightUrl: record.get("TestFlight URL"),
      demoUrl: record.get("Live URL (URL to deployed site)") || record.get("TestFlight URL"),
      videoDemo: record.get("Video Demo URL"),
      expoSnackUrl: record.get("Expo Snack URL"),
      images: record.get("Screenshot") || [],
    }));

    res.status(200).json(submissions.reverse());
  } catch (error) {
    console.error("Error fetching submissions:", error);
    res.status(500).json({ error: "Error fetching submissions" });
  }
}
