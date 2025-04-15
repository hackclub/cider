// Credits to @crnicholson for the footer

export default function Footer() {
  return (
    <footer className="bg-hack-black text-white py-16 px-6 md:px-10">
      <div className="w-full mx-auto">
        <div className="flex flex-col md:flex-row justify-between gap-12 mb-12">
          <div className="md:w-1/2">
            <h2 className="font-bold text-3xl mb-6">A project by Hack Club</h2>
            <p className="text-white/80 text-lg mb-6 max-w-xl">
              Hack Club is a registered 501(c)3 nonprofit organization that supports a network of 20k+
              technical high schoolers. We believe you learn best by building when you're learning and
              shipping technical projects with your friends, so we've started You Ship, We Ship, a program
              where you ship a technical project and we ship you something in exchange.
            </p>
            <p className="text-white/80 text-lg">
              In the past few years, we{" "}
              <a href="https://hackclub.com/onboard" className="text-hack-orange hover:underline">
                fabricated custom PCBs designed by 265 teenagers
              </a>
              ,{" "}
              <a href="https://github.com/hackclub/the-hacker-zephyr" className="text-hack-blue hover:underline">
                hosted the world's longest hackathon on land
              </a>
              , and{" "}
              <a href="https://hackclub.com/winter" className="text-hack-green hover:underline">
                gave away $75k of hardware
              </a>
              .
            </p>
          </div>
          
          <div className="grid grid-cols-2 gap-x-12 gap-y-8">
            <div>
              <h3 className="font-bold text-xl mb-4">Hack Club</h3>
              <ul className="space-y-2">
                <li><a href="https://hackclub.com/philosophy" className="text-white/80 hover:text-white hover:underline transition">Philosophy</a></li>
                <li><a href="https://hackclub.com/team" className="text-white/80 hover:text-white hover:underline transition">Our Team &amp; Board</a></li>
                <li><a href="https://hackclub.com/jobs" className="text-white/80 hover:text-white hover:underline transition">Jobs</a></li>
                <li><a href="https://hackclub.com/brand" className="text-white/80 hover:text-white hover:underline transition">Branding</a></li>
                <li><a href="https://hackclub.com/press" className="text-white/80 hover:text-white hover:underline transition">Press Inquiries</a></li>
                <li><a href="https://hackclub.com/donate" className="text-white/80 hover:text-white hover:underline transition">Donate</a></li>
              </ul>
            </div>
            
            <div>
              <h3 className="font-bold text-xl mb-4">Resources</h3>
              <ul className="space-y-2">
                <li><a href="https://hackclub.com/community" className="text-white/80 hover:text-white hover:underline transition">Community</a></li>
                <li><a href="https://hackclub.com/onboard" className="text-white/80 hover:text-white hover:underline transition">OnBoard</a></li>
                <li><a href="https://sprig.hackclub.com" className="text-white/80 hover:text-white hover:underline transition">Sprig</a></li>
                <li><a href="https://blot.hackclub.com" className="text-white/80 hover:text-white hover:underline transition">Blot</a></li>
                <li><a href="https://hackclub.com/bin" className="text-white/80 hover:text-white hover:underline transition">Bin</a></li>
                <li><a href="https://jams.hackclub.com" className="text-white/80 hover:text-white hover:underline transition">Jams</a></li>
              </ul>
            </div>
          </div>
        </div>
        
        <div className="border-t border-white/20 pt-8 text-center md:text-left flex flex-col md:flex-row justify-between items-center">
          <p className="text-white/60">© 2025 Hack Club. 501(c)(3) nonprofit (EIN: 81-2908499).</p>
          <div className="mt-4 md:mt-0 flex space-x-4">
            <a href="https://twitter.com/hackclub" className="text-white/60 hover:text-white transition">Twitter</a>
            <a href="https://github.com/hackclub" className="text-white/60 hover:text-white transition">GitHub</a>
            <a href="https://hackclub.com/slack" className="text-white/60 hover:text-white transition">Slack</a>
          </div>
        </div>
      </div>
    </footer>
  );
}
