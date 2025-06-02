import Balancer from "react-wrap-balancer";
import { useForm, Controller } from "react-hook-form";
import { useState } from "react";
import Footer from "../components/footer";
import { steps } from "../data/steps";
import { requirements } from "../data/requirements";
import Question from "../components/Question";
import { faqs } from "../data/faqs";
import { SubmissionCard } from "./submissions";
import Head from "../components/head.js";
import Banner from "../components/Banner.js";
import MetaData from "../components/Meta.js";
import Airtable from "airtable";
import { Client } from "@googlemaps/google-maps-services-js";

const geocodeCache = new Map();

const getAirtableBase = () => {
  return new Airtable({ apiKey: process.env.AIRTABLE_API_KEY }).base(
    process.env.AIRTABLE_BASE_ID
  );
};

async function getCoordinates(city, country) {
  if (!city && !country) return null;
  if (!process.env.GOOGLE_MAPS_API_KEY) return null;
  
  const cacheKey = `${city || ''}-${country || ''}`;
  
  if (geocodeCache.has(cacheKey)) {
    return geocodeCache.get(cacheKey);
  }
  
  try {
    const googleMapsClient = new Client({});
    const locationQuery = [city, country].filter(Boolean).join(", ");
    
    const response = await googleMapsClient.geocode({
      params: {
        address: locationQuery,
        key: process.env.GOOGLE_MAPS_API_KEY
      },
      timeout: 5000 
    });
    
    if (response.data.results && response.data.results.length > 0) {
      const location = response.data.results[0].geometry.location;
      const result = {
        latitude: location.lat,
        longitude: location.lng
      };
      
      geocodeCache.set(cacheKey, result);
      
      return result;
    }
    
    return null;
  } catch (error) {
    console.error('Geocoding error:', error.message);
    return null;
  }
}

export async function getServerSideProps() {
  try {
    const base = getAirtableBase();
    const records = await base("Demo Submissions").select({ view: "Granted" }).all();

    const submissions = records.map((record) => {
      const city = record.get("City") || null;
      const country = record.get("Country") || null;
      
      const coordinates = record.get("Coordinates") || null;
      
      return {
        id: record.id,
        name: record.get("App Name"),
        description: record.get("Short Description"),
        author: `${record.get("First Name")} ${record.get("Last Name") || ""}`,
        githubUsername: record.get("GitHub username"),
        slackId: record.get("Hack Club Slack ID"),
        githubUrl: record.get("Code URL (URL to GitHub / other code host repo)"),
        demoUrl: record.get("Live URL (URL to deployed site)") || record.get("TestFlight URL"),
        images: record.get("Screenshot") || [],
        location: {
          city,
          country,
          coordinates
        }
      };
    });
    
    const geocodingPromises = [];
    
    submissions.forEach((submission) => {
      const { city, country } = submission.location;
      
      if (submission.location.coordinates || (!city && !country)) {
        return;
      }
      
      geocodingPromises.push(
        getCoordinates(city, country).then(coordinates => {
          if (coordinates) {
            submission.location.coordinates = coordinates;
          }
        })
      );
    });
    
    if (geocodingPromises.length > 0) {
      await Promise.all(geocodingPromises);
    }

    return {
      props: {
        submissions: submissions.reverse().slice(0, 3),
      },
    };
  } catch (error) {
    console.error("Error fetching submissions:", error);
    return {
      props: {
        submissions: [],
        error: error.message,
      },
    };
  }
}

export default function Home({ submissions, error }) {
  const { handleSubmit, control, formState: { isSubmitting } } = useForm();
  const [submissionStatus, setSubmissionStatus] = useState(null);

  const onSubmit = async (data) => {
    try {
      await fetch("/api/submit", {
        method: "POST",
        body: JSON.stringify(data),
        headers: {
          "Content-Type": "application/json",
        },
      });
      setSubmissionStatus("success");
    } catch (error) {
      console.error("Error submitting form:", error);
      setSubmissionStatus("error");
    }
  };

  return (
    <main className="flex flex-col items-center">
      <Head />
      <MetaData />
      
      <a href="http://hackclub.com">
        <img
          src="/flag.svg"
          className="absolute top-12 left-4 w-1/4 lg:w-1/12 hover:transform hover:-rotate-12 hover:duration-300 hover:ease-in-out z-40"
        />
      </a>
      
      <div className="w-full h-full flex flex-col items-center header-gradient min-h-screen pt-16">
        <section className="flex flex-col items-center justify-center min-h-[70vh] gap-6 w-10/12 lg:w-1/2 text-white">
          <img src="/logo.svg" className="w-60 md:w-80 mb-4" />
          <h2 className="text-4xl md:text-5xl text-center text-white font-bold">
            <Balancer ratio={0.2}>
              Design, Code, and Ship an iOS app to the App Store in 30 days
            </Balancer>
          </h2>
          <p className="text-lg md:text-xl text-center opacity-90 max-w-2xl">
            Get a $100 grant for an Apple Developer Membership and build something amazing with Hack Club.
          </p>
          <div className="flex flex-col sm:flex-row items-center justify-center gap-4 mt-4">
            <a
              href="https://forms.hackclub.com/t/jALEZHqGE2us"
              target="_blank"
              className="btn bg-white text-red font-bold text-lg px-6 py-3 rounded-lg shadow-lg hover:shadow-xl transition-all"
            >
              Submit&nbsp;Demo
            </a>
            <a
              href="https://github.com/hackclub/cider-website#make-your-pr"
              target="_blank"
              className="btn bg-red/10 backdrop-blur-sm text-white border-2 border-white px-6 py-3 font-bold text-lg rounded-lg hover:bg-white/20 transition-all"
            >
              Submit&nbsp;PR
            </a>
          </div>
        </section>
        
        <div className="w-10/12 sm:w-auto max-w-xl mb-16 bg-white/10 backdrop-blur-sm p-6 rounded-xl border border-white/30 shadow-xl">
          <h3 className="text-white text-xl font-bold mb-4">Get your $100 grant for Apple Developer Membership</h3>
          <form
            className="flex flex-col gap-4"
            onSubmit={handleSubmit(onSubmit)}
          >
            <Controller
              name="email"
              control={control}
              rules={{
                required: "Email is required",
                pattern: {
                  value: /^[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,}$/i,
                  message: "Invalid email address"
                }
              }}
              render={({ field, fieldState }) => (
                <div className="space-y-1">
                  <div className="relative">
                    <div className="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none">
                      <svg xmlns="http://www.w3.org/2000/svg" className="h-5 w-5 text-white/70" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                        <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M3 8l7.89 5.26a2 2 0 002.22 0L21 8M5 19h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v10a2 2 0 002 2z" />
                      </svg>
                    </div>
                    <input
                      required
                      type="email"
                      className="text-white placeholder:text-white/70 text-lg w-full rounded-lg border-2 border-white/40 focus:border-white bg-white/5 py-3 pl-10 pr-4 focus:outline-none data-[focus]:outline-2 transition"
                      placeholder="fayd@hackclub.com"
                      {...field}
                    />
                  </div>
                  {fieldState.error && (
                    <p className="text-white/80 text-sm">{fieldState.error.message}</p>
                  )}
                </div>
              )}
            />
            <button
              type="submit"
              disabled={isSubmitting}
              className="bg-white text-red px-6 py-3 font-bold text-lg rounded-lg hover:bg-white/90 transition-all shadow-lg hover:shadow-xl flex items-center justify-center"
            >
              {isSubmitting ? (
                <>
                  <svg className="animate-spin -ml-1 mr-2 h-5 w-5 text-red" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24">
                    <circle className="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" strokeWidth="4"></circle>
                    <path className="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path>
                  </svg>
                  Processing...
                </>
              ) : "Sign up for the grant"}
            </button>
          </form>
        </div>
      </div>
      
      <section
        id="prompt"
        className="section-padding flex flex-col justify-center gap-8 w-11/12 max-w-6xl"
      >
        <div className="text-center mb-6">
          <h2 className="text-4xl md:text-5xl mb-4">How It Works</h2>
          <p className="text-xl text-hack-muted max-w-3xl mx-auto">
            <Balancer>
              Build an app that improves an aspect of your (and your friends') lives
            </Balancer>
          </p>
        </div>
        
        <div className="grid md:grid-cols-2 lg:grid-cols-3 gap-6">
          {steps.map(({ heading, description, link, primary }, index) => (
            <div
              key={index}
              className={`card flex flex-col justify-between gap-4 p-6 ${
                primary ? "border-2 border-red md:transform md:scale-105" : ""
              }`}
            >
              <div className="flex flex-col">
                <span className="text-sm font-bold text-hack-muted mb-1">STEP {index + 1}</span>
                <h3 className="text-xl font-bold text-hack-black mb-2">
                  {heading}
                </h3>
                <p className="text-hack-muted">
                  {description}
                </p>
              </div>
              {link && (
                <a
                  href={link}
                  className="text-red font-bold flex items-center gap-1 hover:underline"
                >
                  Submit{" "}
                  <svg
                    width="20"
                    height="20"
                    viewBox="0 0 24 24"
                    fill="none"
                    xmlns="http://www.w3.org/2000/svg"
                    className="inline"
                  >
                    <path
                      d="M15.0378 6.34317L13.6269 7.76069L16.8972 11.0157L3.29211 11.0293L3.29413 13.0293L16.8619 13.0157L13.6467 16.2459L15.0643 17.6568L20.7079 11.9868L15.0378 6.34317Z"
                      fill="currentColor"
                    />
                  </svg>
                </a>
              )}
            </div>
          ))}
        </div>
      </section>
      
      <section className="section-padding bg-white w-full">
        <div className="max-w-6xl mx-auto w-11/12">
          <h2 className="text-4xl md:text-5xl mb-8 text-center">Project Requirements</h2>
          <div className="bg-hack-smoke p-8 rounded-xl">
            <ul className="grid md:grid-cols-2 gap-4">
              {requirements.map((requirement, index) => (
                <li key={index} className="flex items-start gap-3">
                  <div className="mt-1 text-red">
                    <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
                      <polyline points="20 6 9 17 4 12"></polyline>
                    </svg>
                  </div>
                  <span className="text-hack-black">{requirement}</span>
                </li>
              ))}
            </ul>
          </div>
        </div>
      </section>
      
      <section className="section-padding flex flex-col items-center gap-12 justify-center w-11/12 max-w-6xl">
        <div className="text-center">
          <h2 className="text-4xl md:text-5xl mb-4">Cider tastes better with friends...</h2>
          <p className="text-xl text-hack-muted max-w-3xl mx-auto">
            Check out what others in the community have built!
          </p>
        </div>
        
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-8 w-full">
          {submissions.map((submission, index) => (
            <SubmissionCard key={index} submission={submission} />
          ))}
        </div>
        
        <a
          href="/submissions"
          className="btn btn-outline text-lg font-bold px-6 py-3 rounded-lg"
        >
          View all submissions
        </a>
      </section>
      
      <section className="section-padding bg-gray-50 w-full">
        <div className="max-w-6xl mx-auto w-11/12">
          <h2 className="text-4xl md:text-5xl mb-12 text-center">Frequently Asked Questions</h2>
          <div className="grid md:grid-cols-2 gap-8">
            {faqs.map(({ question, answer }, index) => (
              <Question key={index} heading={question} description={answer} />
            ))}
          </div>
        </div>
      </section>
      
      <section className="my-16 flex flex-col items-center justify-center gap-8 w-11/12 max-w-4xl text-center">
        <h2 className="text-4xl md:text-5xl">
          <Balancer>
            Ready to build your iOS app?
          </Balancer>
        </h2>
        <p className="text-xl text-hack-muted max-w-3xl">
          Join our community, get $100 for your Apple Developer Membership, and ship in 30 days!
        </p>
        
        <div className="w-full max-w-xl mt-4 bg-hack-smoke p-8 rounded-xl shadow-md border border-gray-100">
          <form className="flex flex-col gap-4" onSubmit={handleSubmit(onSubmit)}>
            <Controller
              name="email"
              control={control}
              rules={{
                required: "Email is required",
                pattern: {
                  value: /^[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,}$/i,
                  message: "Invalid email address"
                }
              }}
              render={({ field, fieldState }) => (
                <div className="space-y-1">
                  <label htmlFor="email-signup" className="block text-left text-hack-black font-bold mb-2">Your Email</label>
                  <div className="relative">
                    <div className="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none">
                      <svg xmlns="http://www.w3.org/2000/svg" className="h-5 w-5 text-hack-muted" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                        <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M3 8l7.89 5.26a2 2 0 002.22 0L21 8M5 19h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v10a2 2 0 002 2z" />
                      </svg>
                    </div>
                    <input
                      id="email-signup"
                      required
                      type="email"
                      className="text-hack-black placeholder:text-hack-muted/60 text-lg w-full rounded-lg border-2 border-gray-200 focus:border-red bg-white py-3 pl-10 pr-4 focus:outline-none shadow-sm"
                      placeholder="fayd@hackclub.com"
                      {...field}
                    />
                  </div>
                  {fieldState.error && (
                    <p className="text-red text-sm text-left">{fieldState.error.message}</p>
                  )}
                </div>
              )}
            />
            <button
              type="submit"
              disabled={isSubmitting}
              className="btn btn-primary text-lg font-bold py-3 px-6 mt-2"
            >
              {isSubmitting ? (
                <>
                  <svg className="animate-spin -ml-1 mr-2 h-5 w-5 text-white" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24">
                    <circle className="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" strokeWidth="4"></circle>
                    <path className="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path>
                  </svg>
                  Processing...
                </>
              ) : "Sign up for the grant"}
            </button>
          </form>
        </div>
        
        <div className="mt-16 text-center">
          <a
            target="_blank"
            href="https://hackclub.com/slack?event=%23cider"
            className="btn btn-primary text-lg font-bold px-8 py-3 uppercase"
          >
            Join us on Slack
          </a>
          <p className="text-hack-muted mt-4">
            Already have an account? Join the{" "}
            <a
              href="https://app.slack.com/client/T0266FRGM/C073DTGENJ2"
              className="text-red font-medium underline"
            >
              #cider
            </a>{" "}
            channel!
          </p>
        </div>
      </section>
      
      <Footer />
    </main>
  );
}
