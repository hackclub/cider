export default function Testimonial({ image, name, author, link, description }) {
  return (
    <a href={link} className="block hover:scale-105 transition-all" target="_blank">
      <div className="card flex flex-col h-full p-6">
        {image && (
          <img
            src={image}
            className="w-16 h-16 rounded-lg object-cover mb-4"
            alt={name}
          />
        )}
        <h3 className="text-xl font-bold text-hack-black mb-2">{name}</h3>
        <p className="text-hack-muted mb-4 flex-grow">{description}</p>
        <p className="text-red font-bold">—&nbsp;{author}</p>
      </div>
    </a>
  );
}
