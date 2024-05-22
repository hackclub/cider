import '../styles/globals.css'
import { ThemeProvider } from 'next-themes'
import { Provider } from 'react-wrap-balancer'

function MyApp({ Component, pageProps }) {
  return (
    <ThemeProvider defaultTheme="system" attribute="class">
      <Provider>
        <Component {...pageProps} />
      </Provider>
    </ThemeProvider>
  )
}

export default MyApp
