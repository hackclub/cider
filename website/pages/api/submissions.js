import Airtable from "airtable";
import { Client } from "@googlemaps/google-maps-services-js";

const API_SECRET_KEY = process.env.API_SECRET_KEY;
const GOOGLE_MAPS_API_KEY = process.env.GOOGLE_MAPS_API_KEY;

const googleMapsClient = new Client({});

if (!API_SECRET_KEY) {
  console.warn('WARNING: API_SECRET_KEY is not set in environment variables. API will be accessible without authentication in development mode only.');
}

if (!GOOGLE_MAPS_API_KEY) {
  console.warn('WARNING: GOOGLE_MAPS_API_KEY is not set in environment variables. Geocoding functionality will not work correctly.');
}

const base = new Airtable({ apiKey: process.env.AIRTABLE_API_KEY }).base(
  process.env.AIRTABLE_BASE_ID
);

const geocodeCache = new Map();

async function getCoordinates(city, country) {
  if (!city && !country) return null;
  if (!GOOGLE_MAPS_API_KEY) return null;
  
  // Create a cache key from city and country
  const cacheKey = `${city || ''}-${country || ''}`;
  
  // Check if we already have these coordinates cached
  if (geocodeCache.has(cacheKey)) {
    return geocodeCache.get(cacheKey);
  }
  
  try {
    const locationQuery = [city, country].filter(Boolean).join(", ");
    
    const response = await googleMapsClient.geocode({
      params: {
        address: locationQuery,
        key: GOOGLE_MAPS_API_KEY
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

export default async function handler(req, res) {
  const isDev = process.env.NODE_ENV === 'development';
  const skipAuth = isDev && !API_SECRET_KEY;
  
  if (!skipAuth) {
    const authHeader = req.headers.authorization;
    
    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      return res.status(401).json({ error: "Unauthorized - Missing authentication" });
    }
    
    const providedToken = authHeader.split(' ')[1];
    
    try {
      const crypto = require('crypto');
      const expectedToken = API_SECRET_KEY;
      const isValid = crypto.timingSafeEqual(
        Buffer.from(providedToken, 'base64'),
        Buffer.from(expectedToken, 'base64')
      );
      
      if (!isValid) {
        return res.status(403).json({ error: "Forbidden - Invalid authentication token" });
      }
    } catch (e) {
      return res.status(403).json({ error: "Forbidden - Invalid authentication token" });
    }
  }
  
  try {
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
        testflightUrl: record.get("TestFlight URL"),
        demoUrl: record.get("Live URL (URL to deployed site)") || record.get("TestFlight URL"),
        videoDemo: record.get("Video Demo URL"),
        expoSnackUrl: record.get("Expo Snack URL"),
        images: record.get("Screenshot") || [],
        location: {
          city,
          country,
          coordinates
        }
      };
    });
    
    const geocodingPromises = [];
    
    submissions.forEach((submission, index) => {
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

    res.status(200).json(submissions.reverse());
  } catch (error) {
    console.error("Error fetching submissions:", error);
    res.status(500).json({ error: "Error fetching submissions" });
  }
}
