import Head from 'next/head'

export default function HeadObject({children}) {
    const title = "Hack Club - Cider";
    const description = "Design, Code, and Ship an iOS app to the App Store in 30 days with Hack Club's Cider program. Get a $100 grant for an Apple Developer Membership!";
    const image = "https://cloud-3n5q60w3u-hack-club-bot.vercel.app/0cider-banner.png";
    const url = "https://cider.hackclub.com";
    
    return (
        <Head>
            <meta charSet="utf-8" />
            <meta httpEquiv="X-UA-Compatible" content="IE=edge" />
            <meta name="viewport" content="width=device-width,initial-scale=1" />
            <title>{title}</title>
            
            {/* Primary Meta Tags */}
            <meta name="title" content={title} />
            <meta name="description" content={description} />
            <meta name="keywords" content="hack club, cider, iOS app, apple developer, coding, programming, high school, students, hackathon" />
            <meta name="author" content="Hack Club" />
            
            {/* Open Graph / Facebook */}
            <meta property="og:type" content="website" />
            <meta property="og:url" content={url} />
            <meta property="og:title" content={title} />
            <meta property="og:description" content={description} />
            <meta property="og:image" content={image} />
            
            {/* Twitter */}
            <meta property="twitter:card" content="summary_large_image" />
            <meta property="twitter:url" content={url} />
            <meta property="twitter:title" content={title} />
            <meta property="twitter:description" content={description} />
            <meta property="twitter:image" content={image} />
            <meta name="twitter:creator" content="@hackclub" />
            <meta name="twitter:site" content="@hackclub" />

            {/* Favicons */}
            <link rel="icon" href="https://assets.hackclub.com/icon-rounded.svg" />
            <link rel="apple-touch-icon" href="https://assets.hackclub.com/icon-rounded.svg" />
            
            {/* Analytics */}
            <script defer data-domain="cider.hackclub.com" src="https://plausible.io/js/script.pageview-props.tagged-events.js"></script>
            
            {/* iOS App Banner */}
            <meta name="apple-itunes-app" content="app-argument=https://cider.hackclub.com" />
            
            {/* Theme Color */}
            <meta name="theme-color" content="#ec3750" />
            
            {children}
        </Head>
    )
}
