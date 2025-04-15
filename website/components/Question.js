export default function Question({ heading, description }) {
  return (
    <div className="bg-white rounded-lg shadow-md hover:shadow-xl p-6 border border-gray-100 transition-all duration-300 transform hover:-translate-y-1">
      <h3 className="text-xl font-bold text-hack-black mb-3">{heading}</h3>
      <p className="text-hack-muted">{description}</p>
    </div>
  );
}
