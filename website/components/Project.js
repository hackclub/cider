export default function Testimonial({ image, name, author, link, description }) {
  return (
    <a href={link} className="hover:scale-105 transition-all" target="_blank">
      <div className="flex flex-col items-left justify-between gap-4 border border-gray-400 lg:w-64 w-full rounded-xl p-8 lg:h-full">
        {/* {image && (
        <img
          src={image}
          className="size-14 rounded-lg bg-white object-contain border border-gray-300"
        />
      )} */}
        <p className="text-xl font-medium text-gray-700">
          {name}
          <br />
          <span className="text-base text-gray-500">{description}</span>
        </p>
        <p className="text-lg font-semibold text-red">-&nbsp;{author}</p>
      </div>
    </a>
  );
}
