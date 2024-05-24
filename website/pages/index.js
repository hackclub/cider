import Balancer from "react-wrap-balancer";
import { useForm, Controller } from "react-hook-form";
import Project from "../components/Project";
import useSWR from "swr";
import fetcher from "../lib/fetcher";
import Footer from "../components/footer";
import { steps } from "../data/steps";
import { requirements } from "../data/requirements";
import { projects } from "../data/projects";
import Question from "../components/Question";
import { faqs } from "../data/faqs";

export default function Home() {
  const { handleSubmit, control } = useForm();

  const onSubmit = (data) => {
    fetch("/api/submit", {
      method: "POST",
      body: JSON.stringify(data),
      headers: {
        "Content-Type": "application/json",
      },
    });
    alert("Your email has been submitted! 🎉");
  };

  const { data } = useSWR("/api/time", fetcher);

  return (
    <main className="flex flex-col items-center">
      <a href="http://hackclub.com">
        <img
          src="/flag.svg"
          className="absolute top-0 left-4 w-1/4 lg:w-1/12 hover:transform hover:-rotate-12 hover:-top-2 hover:duration-300 hover:ease-in-out"
        />
      </a>
      <div className="w-full h-full flex flex-col items-center gradient-bg">
        <section className="flex flex-col items-center justify-center min-h-screen gap-4 w-10/12 lg:w-1/3">
          <h2 className="text-2xl">Beta running from June 1st to June 30th</h2>
          <img src="/logo.svg" />
          <h2 className="text-4xl text-center">
            <Balancer ratio={0.2} className="">
              Design, Code, and Ship an iOS app to the App Store in 30 days
            </Balancer>
          </h2>
          {/* <div className="flex items-center justify-center gap-2">
            <a
              href="https://forms.hackclub.com/t/jALEZHqGE2us"
              target="_blank"
              className="badge text-4xl mt-4 !text-white bg-red"
            >
              Submit&nbsp;Demo
            </a>
            <a href="#prompt" className="badge text-4xl mt-4 hover:bg-red hover:text-white">
              Learn&nbsp;More
            </a>
          </div> */}
          <form className="flex gap-2" onSubmit={handleSubmit(onSubmit)}>
            <Controller
              name="email"
              control={control}
              render={({ field }) => (
                <input
                  required
                  type="email"
                  className="text-red placeholder:text-red/60 text-lg w-full rounded-lg border-2 border-red focus:border-red bg-transparent py-1.5 px-3 focus:outline-none data-[focus]:outline-2 data-[focus]:-outline-offset-2 data-[focus]:outline-white/25"
                  placeholder="fayd@hackclub.com"
                  {...field}
                />
              )}
            />
            <input
              type="submit"
              value="Sign up for the grant"
              className="text-white bg-red px-4 py-2 font-medium text-lg font-sans text-center rounded-lg"
            />
          </form>
          {/* <img
          src="/apple-throws-airplane.png"
          className="w-1/4 lg:w-1/6 absolute bottom-10 right-20 xl:right-60"
        />
        <img
          src="/apple-building-blocks.png"
          className="w-1/4 lg:w-1/6 absolute left-20 xl:left-60 bottom-10"
        /> */}
        </section>
      </div>
      <section
        id="prompt"
        className="min-h-screen flex flex-col justify-center gap-4 w-5/6 my-12 lg:mt-0 md:w-11/12 2xl:w-2/3"
      >
        {/* <div className="flex flex-col md:flex-row md:items-center gap-4">
          <h1 className="badge">Prompt</h1>
          <p className="text-xl xl:text-2xl font-medium text-gray-700">
            <Balancer>
              Build an app that improves an aspect of your (and your friends’) lives
            </Balancer>
          </p>
        </div> */}
        <div className="hidden xl:block border-t border-gray-300 transform translate-y-40" />
        <div className="flex flex-col xl:flex-row gap-5 xl:gap-10 mt-4">
          {steps.map(({ heading, description, link }, index) => (
            <div
              key={index}
              className="flex flex-col xl:justify-between xl:w-1/2 gap-1 bg-soft-white xl:p-5 xl:border xl:border-gray-300 xl:rounded-xl z-10 xl:shadow-lg"
            >
              <div className="flex flex-col">
                <h3 className="text-xl xl:text-2xl font-semibold text-red">{heading}</h3>
                <p className="text-base xl:text-lg font-medium text-gray-700">{description}</p>
              </div>
              {link && (
                <a href={link} className="text-red text-base xl:text-lg font-medium">
                  Submit{" "}
                  <svg
                    width="24"
                    height="24"
                    viewBox="0 0 24 24"
                    fill="none"
                    xmlns="http://www.w3.org/2000/svg"
                    className="inline"
                  >
                    <path
                      d="M15.0378 6.34317L13.6269 7.76069L16.8972 11.0157L3.29211 11.0293L3.29413 13.0293L16.8619 13.0157L13.6467 16.2459L15.0643 17.6568L20.7079 11.9868L15.0378 6.34317Z"
                      fill="currentColor"
                    />
                  </svg>
                </a>
              )}
            </div>
          ))}
        </div>
        <div className="flex flex-col gap-4 my-10">
          <h1 className="badge">Requirements</h1>
          <ul className="list-disc list-inside">
            {requirements.map((requirement, index) => (
              <li key={index} className="xl:text-lg font-base text-gray-700">
                {requirement}
              </li>
            ))}
          </ul>
        </div>
      </section>
      <section className="my-14 flex flex-col lg:items-center gap-10 justify-center w-5/6 lg:w-11/12">
        <h2 className="text-6xl text-center">Cider tastes better with friends...</h2>
        {/* <img
          src="/apple-with-friends.png"
          className="w-1/2 md:w-1/4 lg:w-[12%] -mt-16 mb-0 mx-auto"
        /> */}
        <div className="flex flex-col lg:flex-row lg:flex-wrap gap-4">
          {projects.map((project, index) => (
            <Project key={index} {...project} />
          ))}
        </div>
      </section>
      <section className="my-20 lg:mt-40 flex flex-col justify-center gap-4 w-11/12 lg:w-2/3">
        <h1 className="badge">Frequently Asked Questions</h1>
        <div className="grid lg:grid-cols-2 gap-4 lg:gap-2">
          {faqs.map(({ question, answer }, index) => (
            <Question key={index} heading={question} description={answer} />
          ))}
        </div>
      </section>
      <section className="mb-20 lg:my-20 flex flex-col justify-center gap-4 w-5/6 lg:w-2/3">
        <h2 className="text-5xl">
          <Balancer>Design, Code, And Ship an iOS app to the App Store in 30 days</Balancer>
        </h2>
        <form className="flex flex-col my-4" onSubmit={handleSubmit(onSubmit)}>
          <Controller
            name="email"
            control={control}
            render={({ field }) => (
              <input
                required
                type="email"
                className="text-red placeholder:text-red/60 text-lg w-full rounded-lg border-2 border-red focus:border-red bg-transparent py-1.5 px-3 focus:outline-none data-[focus]:outline-2 data-[focus]:-outline-offset-2 data-[focus]:outline-white/25"
                placeholder="fayd@hackclub.com"
                {...field}
              />
            )}
          />
          <input
            type="submit"
            value="Sign up for the grant"
            className="badge text-2xl mt-4 hover:bg-red hover:text-white"
          />
        </form>
        <p className="italic text-red/50 text-2xl hover:text-red hover:transition hover:duration-300">
          kickoff call in {data ? data.time : "loading..."} (join #cider)
        </p>
        <div className="mt-12 max-w-screen-lg mx-auto rounded-lg">
          <div className="text-center">
            <a
              target="_blank"
              href="https://hackclub.com/slack?event=%23cider"
              className="rounded-full cursor-pointer bg-red text-white px-6 py-3 font-semibold text-xl"
            >
              JOIN SLACK
            </a>
            <p className="text-gray-400 mt-4">
              Already have an account? Join the{" "}
              <a
                href="https://app.slack.com/client/T0266FRGM/C073DTGENJ2"
                className="text-red underline"
              >
                #cider
              </a>{" "}
              channel!
            </p>
          </div>
        </div>
        {/* <img
          src="/apple-stretches.png"
          className="w-24 hidden lg:block absolute lg:right-72"
        /> */}
      </section>
      <Footer />
    </main>
  );
}
