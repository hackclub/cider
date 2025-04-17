import { useState } from "react";
import { motion } from "framer-motion";
import Image from "next/image";
import { Carousel } from "react-responsive-carousel";
import "react-responsive-carousel/lib/styles/carousel.min.css";
import Footer from "../components/footer";
import Head from "../components/head";
import Meta from "../components/Meta";
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
      
      // Cache the result for future use
      geocodeCache.set(cacheKey, result);
      
      return result;
    }
    
    return null;
  } catch (error) {
    console.error('Geocoding error:', error.message);
    return null;
  }
}

// Server-side data fetching
export async function getServerSideProps() {
  try {
    const base = getAirtableBase();
    const records = await base("Demo Submissions").select({ view: "Granted" }).all();

    // Process all submissions
    const submissions = records.map((record) => {
      const city = record.get("City") || null;
      const country = record.get("Country") || null;
      
      // Use existing coordinates if available in the record
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
        submissions: submissions.reverse(),
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

export default function SubmissionsPage({ submissions, error }) {
  const [searchTerm, setSearchTerm] = useState("");
  const [selectedSubmission, setSelectedSubmission] = useState(null);
  
  const isLoading = !submissions && !error;

  const filteredSubmissions = submissions ? submissions.filter(
    (submission) =>
      submission.name.toLowerCase().includes(searchTerm.toLowerCase()) ||
      submission.description.toLowerCase().includes(searchTerm.toLowerCase()) ||
      submission.author.toLowerCase().includes(searchTerm.toLowerCase()) ||
      (submission.location?.city && submission.location.city.toLowerCase().includes(searchTerm.toLowerCase())) ||
      (submission.location?.country && submission.location.country.toLowerCase().includes(searchTerm.toLowerCase()))
  ) : [];

  return (
    <div className="flex flex-col min-h-screen">
      <Head />
      <Meta 
        title="App Gallery" 
        description="Explore amazing iOS apps created by the Hack Club community through the Cider program."
        url="https://cider.hackclub.com/submissions"
      />
      <a href="http://hackclub.com">
        <img
          src="/flag.svg"
          className="absolute left-4 w-1/4 lg:w-1/12 hover:transform hover:-rotate-12 hover:duration-300 hover:ease-in-out z-40"
        />
      </a>
      
      <div className="header-gradient w-full py-20 px-6 text-center text-white">
        <h1 className="text-5xl text-white md:text-6xl font-bold mb-6 tracking-tight">
          App Gallery
        </h1>
        <p className="text-xl md:text-2xl opacity-95 max-w-2xl mx-auto font-light">
          Discover amazing iOS apps created by the Hack Club community!
        </p>
      </div>
      
      <div className="container mx-auto px-4 py-12 flex-grow">
        <div className="max-w-xl mx-auto mb-12">
          <div className="relative">
            <input
              type="text"
              placeholder="Search by name, description, author, or location..."
              className="w-full p-4 pl-12 text-hack-black bg-white border-2 border-gray-100 rounded-xl shadow-md focus:border-red focus:ring-2 focus:ring-red/20 outline-none transition"
              onChange={(e) => setSearchTerm(e.target.value)}
            />
            <div className="absolute inset-y-0 left-0 pl-4 flex items-center pointer-events-none">
              <svg xmlns="http://www.w3.org/2000/svg" className="h-6 w-6 text-hack-muted" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z" />
              </svg>
            </div>
          </div>
        </div>
        
        {/* Loading state */}
        {isLoading && (
          <div className="col-span-full text-center py-16">
            <div className="animate-spin w-12 h-12 border-4 border-red border-t-transparent rounded-full mx-auto mb-4"></div>
            <p className="text-xl text-hack-muted">Loading submissions...</p>
          </div>
        )}
        
        {/* Error state */}
        {error && (
          <div className="col-span-full text-center py-16 text-red-500">
            <p className="text-xl">Error loading submissions. Please try again later.</p>
            <p className="text-sm mt-2 text-hack-muted">{error}</p>
          </div>
        )}
        
        {/* Submission Grid */}
        {!isLoading && !error && (
          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-8">
            {filteredSubmissions.length > 0 ? (
              filteredSubmissions.map((submission) => (
                <SubmissionCard
                  key={submission.id}
                  submission={submission}
                  onClick={() => setSelectedSubmission(submission)}
                />
              ))
            ) : (
              <div className="col-span-full text-center py-16">
                <p className="text-xl text-hack-muted">No submissions found matching your search criteria.</p>
              </div>
            )}
          </div>
        )}
      </div>
      
      {selectedSubmission && (
        <SubmissionModal
          submission={selectedSubmission}
          onClose={() => setSelectedSubmission(null)}
        />
      )}
      
      <Footer />
    </div>
  );
}

export function SubmissionCard({ submission, onClick }) {
  return (
    <motion.div
      className="card overflow-hidden cursor-pointer h-full flex flex-col hover:shadow-xl transition-all duration-300"
      whileHover={{ scale: 1.02, y: -5 }}
      transition={{ duration: 0.2 }}
      onClick={onClick}
    >
      <div className="relative h-48 overflow-hidden">
        <Image
          src={submission.images[0]?.url || "https://assets.hackclub.com/icon-rounded.png"}
          alt={submission.name}
          layout="fill"
          objectFit="cover"
        />
        <div className="absolute inset-0 bg-gradient-to-t from-black/50 to-transparent opacity-0 hover:opacity-100 transition-opacity duration-300"></div>
      </div>
      <div className="p-6 flex flex-col flex-grow">
        <h2 className="text-xl font-bold mb-1">{submission.name}</h2>
        <p className="text-hack-muted mb-3">by {submission.author}</p>
        <p className="text-hack-black mb-6 line-clamp-3 flex-grow">{submission.description}</p>
        <div className="flex flex-col sm:flex-row gap-3 mt-auto">
          <a
            href={submission.githubUrl}
            target="_blank"
            rel="noopener noreferrer"
            className="btn bg-hack-black text-white px-4 py-2 rounded-lg flex items-center justify-center gap-2 hover:bg-hack-black/90"
            onClick={(e) => e.stopPropagation()}
          >
            <svg
              xmlns="http://www.w3.org/2000/svg"
              width="16"
              height="16"
              viewBox="0 0 24 24"
              fill="none"
              stroke="currentColor"
              strokeWidth="2"
              strokeLinecap="round"
              strokeLinejoin="round"
            >
              <path d="M9 19c-5 1.5-5-2.5-7-3m14 6v-3.87a3.37 3.37 0 0 0-.94-2.61c3.14-.35 6.44-1.54 6.44-7A5.44 5.44 0 0 0 20 4.77 5.07 5.07 0 0 0 19.91 1S18.73.65 16 2.48a13.38 13.38 0 0 0-7 0C6.27.65 5.09 1 5.09 1A5.07 5.07 0 0 0 5 4.77a5.44 5.44 0 0 0-1.5 3.78c0 5.42 3.3 6.61 6.44 7A3.37 3.37 0 0 0 9 18.13V22"></path>
            </svg>
            GitHub
          </a>
          <a
            href={submission.demoUrl}
            target="_blank"
            rel="noopener noreferrer"
            className="btn btn-outline flex items-center justify-center gap-2"
            onClick={(e) => e.stopPropagation()}
          >
            <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
              <path d="M18 13v6a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2V8a2 2 0 0 1-2-2h6"></path>
              <polyline points="15 3 21 3 21 9"></polyline>
              <line x1="10" y1="14" x2="21" y2="3"></line>
            </svg>
            View Demo
          </a>
        </div>
      </div>
    </motion.div>
  );
}

function SubmissionModal({ submission, onClose }) {
  return (
    <motion.div
      className="fixed inset-0 bg-hack-black/70 flex items-center justify-center p-4 z-50 backdrop-blur-sm"
      initial={{ opacity: 0 }}
      animate={{ opacity: 1 }}
      exit={{ opacity: 0 }}
      onClick={onClose}
    >
      <motion.div
        className="bg-white rounded-xl p-6 md:p-8 max-w-4xl w-full max-h-[90vh] overflow-y-auto"
        onClick={(e) => e.stopPropagation()}
        initial={{ scale: 0.95, opacity: 0, y: 20 }}
        animate={{ scale: 1, opacity: 1, y: 0 }}
        transition={{ type: "spring", bounce: 0.3 }}
      >
        <div className="flex justify-between items-start mb-6">
          <div>
            <h2 className="text-3xl font-bold">{submission.name}</h2>
            <p className="text-xl text-hack-muted">by {submission.author}</p>
          </div>
          <button 
            onClick={onClose}
            className="text-hack-muted hover:text-hack-black transition p-1"
            aria-label="Close modal"
          >
            <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
              <line x1="18" y1="6" x2="6" y2="18"></line>
              <line x1="6" y1="6" x2="18" y2="18"></line>
            </svg>
          </button>
        </div>
        
        {submission.images.length > 0 && (
          <div className="mb-8">
            <Carousel 
              infiniteLoop 
              swipeable 
              emulateTouch
              showStatus={false}
              showThumbs={false}
              className="submission-carousel"
            >
              {submission.images.map((image, index) => (
                <div key={index} className="carousel-image-container">
                  <Image
                    src={image.url}
                    alt={`${submission.name} - Image ${index + 1}`}
                    width={800}
                    height={400}
                    objectFit="contain"
                    className="rounded-lg mx-auto"
                  />
                </div>
              ))}
            </Carousel>
          </div>
        )}
        
        <div className="mb-8">
          <h3 className="text-xl font-bold mb-3">About the Project</h3>
          <p className="text-hack-black whitespace-pre-line">{submission.description}</p>
        </div>
        
        <div className="grid grid-cols-1 sm:grid-cols-2 gap-4 mb-8">
          <a
            href={submission.githubUrl}
            target="_blank"
            rel="noopener noreferrer"
            className="btn bg-hack-black text-white px-6 py-3 rounded-lg flex items-center justify-center gap-2 hover:bg-hack-black/90"
          >
            <svg
              xmlns="http://www.w3.org/2000/svg"
              width="20"
              height="20"
              viewBox="0 0 24 24"
              fill="none"
              stroke="currentColor"
              strokeWidth="2"
              strokeLinecap="round"
              strokeLinejoin="round"
            >
              <path d="M9 19c-5 1.5-5-2.5-7-3m14 6v-3.87a3.37 3.37 0 0 0-.94-2.61c3.14-.35 6.44-1.54 6.44-7A5.44 5.44 0 0 0 20 4.77 5.07 5.07 0 0 0 19.91 1S18.73.65 16 2.48a13.38 13.38 0 0 0-7 0C6.27.65 5.09 1 5.09 1A5.07 5.07 0 0 0 5 4.77a5.44 5.44 0 0 0-1.5 3.78c0 5.42 3.3 6.61 6.44 7A3.37 3.37 0 0 0 9 18.13V22" />
            </svg>
            View on GitHub
          </a>
          <a
            href={submission.demoUrl}
            target="_blank"
            rel="noopener noreferrer"
            className="btn btn-outline px-6 py-3 flex items-center justify-center gap-2 font-bold"
          >
            <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
              <path d="M18 13v6a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2V8a2 2 0 0 1-2-2h6"></path>
              <polyline points="15 3 21 3 21 9"></polyline>
              <line x1="10" y1="14" x2="21" y2="3"></line>
            </svg>
            Try the Demo
          </a>
        </div>
      </motion.div>
    </motion.div>
  );
}
