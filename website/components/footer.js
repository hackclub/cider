// Credits to @crnicholson for the footer

export default function Footer() {
  return (
    <footer className="bg-red p-10 text-soft-white prose">
      <h1 className="pb-5 italic text-3xl text-soft-white">A project by Hack Club.</h1>
      <p className="w-[90%] lg:w-3/5">
        Hack Club is a registered 501(c)3 nonprofit organization that supports a network of 20k+
        technical high schoolers. We believe you learn best by building when you're learning and
        shipping technical projects with your friends, so we've started You Ship, We Ship, a program
        where you ship a technical project and we ship you something in exchange. In the past few
        years, we{" "}
        <a href="https://hackclub.com/onboard">fabricated custom PCBs designed by 265 teenagers</a>,{" "}
        <a href="https://github.com/hackclub/the-hacker-zephyr">
          hosted the world's longest hackathon on land
        </a>
        , and{" "}
        <a className="mb-10" href="https://hackclub.com/winter">
          gave away $75k of hardware
        </a>
        .
      </p>
      <br></br>
      <div className="leading-relaxed flex mb-4">
        <div className="width-[300px] flex flex-col">
          <h3 className="font-bold italic">Hack Club</h3>
          <a href="https://hackclub.com/philosophy">Philosophy</a>
          <a href="https://hackclub.com/team">Our Team &amp; Board</a>
          <a href="https://hackclub.com/jobs">Jobs</a>
          <a href="https://hackclub.com/brand">Branding</a>
          <a href="https://hackclub.com/press">Press Inquiries</a>
          <a href="https://hackclub.com/donate">Donate</a>
        </div>
        <div className="pl-10 width-[300px] flex flex-col">
          <h3 className="font-bold italic">Resources</h3>
          <a href="https://hackclub.com/community">Community</a>
          <a href="https://hackclub.com/onboard">OnBoard</a>
          <a href="https://sprig.hackclub.com">Sprig</a>
          <a href="https://blot.hackclub.com">Blot</a>
          <a href="https://hackclub.com/bin">Bin</a>
          <a href="https://jams.hackclub.com">Jams</a>
        </div>
      </div>
      <br></br>
      <p>© 2025 Hack Club. 501(c)(3) nonprofit (EIN: 81-2908499).</p>
    </footer>
  );
}
