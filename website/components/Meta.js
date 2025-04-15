import Head from 'next/head';

export default function MetaData({
  title = "Hack Club - Cider",
  description = "Design, Code, and Ship an iOS app to the App Store in 30 days with Hack Club's Cider program. Get a $100 grant for an Apple Developer Membership!",
  image = "https://cider.hackclub.com/banner.png",
  url = "https://cider.hackclub.com",
  children
}) {
  const fullTitle = title === "Hack Club - Cider" ? title : `${title} | Hack Club Cider`;
  
  return (
    <Head>
      <title>{fullTitle}</title>
      
      <meta name="title" content={fullTitle} />
      <meta name="description" content={description} />
      <meta name="keywords" content="hack club, cider, iOS app, apple developer, coding, programming, high school, students, hackathon" />
      <meta name="author" content="Hack Club" />
      
      <meta property="og:type" content="website" />
      <meta property="og:url" content={url} />
      <meta property="og:title" content={fullTitle} />
      <meta property="og:description" content={description} />
      <meta property="og:image" content={image} />
      {children}
    </Head>
  );
}