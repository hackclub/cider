export default function Testimonial({ image, name, author, link }) {
  return (
    <a href={link} className="hover:scale-105 transition-all" target="_blank">
      <div className="flex flex-col items-left gap-4 border border-gray-400 lg:w-64 w-full rounded-xl p-8">
        {/* {image && (
        <img
          src={image}
          className="size-14 rounded-lg bg-white object-contain border border-gray-300"
        />
      )} */}
        <p className="text-xl font-medium text-gray-700">
          {name}
          <br />
          <span className="text-lg font-semibold text-red">-&nbsp;{author}</span>
        </p>
      </div>
    </a>
  );
}
