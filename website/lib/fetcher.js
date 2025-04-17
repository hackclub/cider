

const API_SECRET_KEY = process.env.API_SECRET_KEY;
console.log('API_SECRET_KEY:', API_SECRET_KEY);

export default async function Fetcher(url, options = {}) {
    const headers = { ...(options.headers || {}) };
    if (API_SECRET_KEY) {
        headers.Authorization = `Bearer ${API_SECRET_KEY}`;
    }
    
    const res = await fetch(url, {
        ...options,
        headers
    });
    
    if (!res.ok) {
        const error = new Error('An error occurred while fetching the data.');
        error.info = await res.json();
        error.status = res.status;
        throw error;
    }
    
    return res.json();
}