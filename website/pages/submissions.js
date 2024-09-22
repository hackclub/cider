import { useState, useEffect } from "react";
import { motion } from "framer-motion";
import Image from "next/image";
import { Carousel } from "react-responsive-carousel";
import "react-responsive-carousel/lib/styles/carousel.min.css";

export default function SubmissionsPage() {
  const [submissions, setSubmissions] = useState([]);
  const [searchTerm, setSearchTerm] = useState("");
  const [selectedSubmission, setSelectedSubmission] = useState(null);

  useEffect(() => {
    fetch("/api/submissions")
      .then((response) => response.json())
      .then((data) => setSubmissions(data))
      .catch((error) => console.error("Error fetching submissions:", error));
  }, []);

  const filteredSubmissions = submissions.filter(
    (submission) =>
      submission.name.toLowerCase().includes(searchTerm.toLowerCase()) ||
      submission.description.toLowerCase().includes(searchTerm.toLowerCase()) ||
      submission.author.toLowerCase().includes(searchTerm.toLowerCase())
  );

  return (
    <div className="container mx-auto px-4 py-8">
      <h1 className="text-4xl font-bold mb-8">Submissions Gallery</h1>
      <input
        type="text"
        placeholder="Search submissions..."
        className="w-full p-2 mb-4 border rounded"
        onChange={(e) => setSearchTerm(e.target.value)}
      />
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
        {filteredSubmissions.map((submission) => (
          <SubmissionCard
            key={submission.id}
            submission={submission}
            onClick={() => setSelectedSubmission(submission)}
          />
        ))}
      </div>
      {selectedSubmission && (
        <SubmissionModal
          submission={selectedSubmission}
          onClose={() => setSelectedSubmission(null)}
        />
      )}
    </div>
  );
}

export function SubmissionCard({ submission, onClick }) {
  return (
    <motion.div
      className="bg-white rounded-lg shadow-md overflow-hidden cursor-pointer"
      whileHover={{ scale: 1.05 }}
      onClick={onClick}
    >
      <div className="relative h-48">
        <Image
          src={submission.images[0].url}
          alt={submission.name}
          layout="fill"
          objectFit="cover"
        />
      </div>
      <div className="p-4">
        <h2 className="text-xl font-semibold mb-2">{submission.name}</h2>
        <p className="text-gray-600 mb-2">{submission.author}</p>
        <p className="text-gray-800 mb-4 line-clamp-3">{submission.description}</p>
        <div className="flex justify-between gap-4">
          <a
            href={submission.githubUrl}
            target="_blank"
            rel="noopener noreferrer"
            className="bg-gray-800 text-white px-4 py-2 rounded w-full text-center"
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
              className="inline-block mr-2"
            >
              <path d="M9 19c-5 1.5-5-2.5-7-3m14 6v-3.87a3.37 3.37 0 0 0-.94-2.61c3.14-.35 6.44-1.54 6.44-7A5.44 5.44 0 0 0 20 4.77 5.07 5.07 0 0 0 19.91 1S18.73.65 16 2.48a13.38 13.38 0 0 0-7 0C6.27.65 5.09 1 5.09 1A5.07 5.07 0 0 0 5 4.77a5.44 5.44 0 0 0-1.5 3.78c0 5.42 3.3 6.61 6.44 7A3.37 3.37 0 0 0 9 18.13V22"></path>
            </svg>
            GitHub
          </a>
          <a
            href={submission.testflightUrl}
            target="_blank"
            rel="noopener noreferrer"
            className="text-red text-lg font-medium rounded-md border-2 border-red px-4 py-1 font-sans text-center w-full hover:bg-red hover:text-white"
          >
            TestFlight
          </a>
        </div>
      </div>
    </motion.div>
  );
}

function SubmissionModal({ submission, onClose }) {
  return (
    <motion.div
      className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center p-4"
      initial={{ opacity: 0 }}
      animate={{ opacity: 1 }}
      exit={{ opacity: 0 }}
      onClick={onClose}
    >
      <motion.div
        className="bg-white rounded-lg p-8 max-w-3xl w-full max-h-[90vh] overflow-y-auto"
        onClick={(e) => e.stopPropagation()}
        initial={{ scale: 0.9, opacity: 0 }}
        animate={{ scale: 1, opacity: 1 }}
      >
        <h2 className="text-3xl font-bold mb-4">{submission.name}</h2>
        <p className="text-xl text-gray-600 mb-4">{submission.author}</p>
        <div className="mb-6">
          <Carousel infiniteLoop swipeable emulateTouch>
            {submission.images.map((image, index) => (
              <div key={index}>
                <Image
                  src={image.url}
                  alt={`${submission.name} - Image ${index + 1}`}
                  width={800}
                  height={400}
                  objectFit="cover"
                  className="rounded-lg max-h-[600px] w-auto"
                />
              </div>
            ))}
          </Carousel>
        </div>
        <p className="text-gray-800 mb-6">{submission.description}</p>
        <div className="flex justify-between mb-6 gap-4">
          <a
            href={submission.githubUrl}
            target="_blank"
            rel="noopener noreferrer"
            className="bg-gray-800 text-white px-4 py-2 rounded w-full text-center"
          >
            <svg
              xmlns="http://www.w3.org/2000/svg"
              width="24"
              height="24"
              viewBox="0 0 24 24"
              fill="none"
              stroke="currentColor"
              strokeWidth="2"
              strokeLinecap="round"
              strokeLinejoin="round"
              className="inline-block mr-2"
            >
              <path d="M9 19c-5 1.5-5-2.5-7-3m14 6v-3.87a3.37 3.37 0 0 0-.94-2.61c3.14-.35 6.44-1.54 6.44-7A5.44 5.44 0 0 0 20 4.77 5.07 5.07 0 0 0 19.91 1S18.73.65 16 2.48a13.38 13.38 0 0 0-7 0C6.27.65 5.09 1 5.09 1A5.07 5.07 0 0 0 5 4.77a5.44 5.44 0 0 0-1.5 3.78c0 5.42 3.3 6.61 6.44 7A3.37 3.37 0 0 0 9 18.13V22" />
            </svg>
            GitHub
          </a>
          <a
            href={submission.testflightUrl}
            target="_blank"
            rel="noopener noreferrer"
            className="text-red text-lg font-medium rounded-md border-2 border-red px-4 py-1 font-sans text-center hover:bg-red hover:text-white w-full"
          >
            TestFlight
          </a>
        </div>
        {submission.videoDemo && (
          <div>
            <h3 className="text-2xl font-semibold mb-4">Video Demo</h3>
            <a
              href={submission.videoDemo}
              target="_blank"
              rel="noopener noreferrer"
              className="block text-center text-red hover:underline"
            >
              {submission.videoDemo}
            </a>
          </div>
        )}
        <button className="mt-8 bg-red-500 text-white px-6 py-3 rounded" onClick={onClose}>
          Close
        </button>
      </motion.div>
    </motion.div>
  );
}
