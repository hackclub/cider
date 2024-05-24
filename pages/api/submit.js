import Airtable from "airtable";
const base = new Airtable({ apiKey: process.env.AIRTABLE_API_KEY }).base(
  process.env.AIRTABLE_BASE_ID
);

export default async (req, res) => {
  try {
    base("Email Submissions").create([{ fields: { Email: req.body.email } }], (err) => {
      if (err) {
        console.error(err);
        return res.status(500).json({ error: "Something went wrong" });
      }

      return res.status(200).json({ message: "Email submitted" });
    });
  } catch (err) {
    console.error(err);
    return res.status(500).json({ error: "Something went wrong" });
  }
};
