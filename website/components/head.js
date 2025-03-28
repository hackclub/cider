import Head from 'next/head'

export default function HeadObject({children}) {
    const title = "Hack Club - Cider";
    return (
        <Head>
            <meta charSet="utf-8" />
            <meta httpEquiv="X-UA-Compatible" content="IE=edge" />
            <meta name="viewport" content="width=device-width,initial-scale=1" />
            <title>{title}</title>
            <link rel="icon" href="https://assets.hackclub.com/icon-rounded.svg" />
	    <script defer data-domain="cider.hackclub.com" src="https://plausible.io/js/script.pageview-props.tagged-events.js"></script>
        </Head>
    )
}
