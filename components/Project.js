export default function Testimonial({ image, description, author }) {
  return (
    <div className="flex flex-col items-left gap-4 border border-gray-400 lg:w-1/3 rounded-xl p-8">
      {image && (
        <img
          src={image}
          className="size-14 rounded-lg bg-white object-contain border border-gray-300"
        />
      )}
      <p className="text-xl font-medium text-gray-700">
        "{description}"
        <br />
        <span className="text-lg font-semibold text-red">- {author}</span>
      </p>
    </div>
  );
}
