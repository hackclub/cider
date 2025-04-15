import React from 'react';

export default function Banner({ 
  text = "🎉 Cider Competition in progress! Check the Slack announcement for details →",
  link = "https://hackclub.slack.com/archives/C0266FRGT/p1742577843129429",
  bgColor = "bg-hack-yellow",
  textColor = "text-hack-black"
}) {
  return (
    <div className={`w-full ${bgColor} py-3 text-center sticky top-0 z-50`}>
      <a 
        href={link}
        className={`${textColor} font-bold hover:underline`}
        target="_blank"
        rel="noopener noreferrer"
      >
        {text}
      </a>
    </div>
  );
}