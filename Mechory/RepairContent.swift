import Foundation

struct CogRepairGuide: Identifiable {
    let id: String
    let title: String
    let symptom: String
    let why: String
    let mechID: String
    let steps: [String]
    let prevention: [String]
    let proNote: String
    let artName: String
}

enum CogRepairContent {
    static let all: [CogRepairGuide] = [
        CogRepairGuide(
            id: "fix-zipper",
            title: "Zipper Stuck Halfway",
            symptom: "The slider grinds to a halt mid-track and won't budge either way.",
            why: "The slider's hidden wedge needs the teeth to glide through its channel. Fabric caught in the channel, or dry, deformed teeth, wedge it solid.",
            mechID: "zipper",
            steps: [
                "Stop pulling hard — force bends the slider and makes it permanent.",
                "Check for caught fabric or thread and ease it out sideways, not down.",
                "Rub a graphite pencil tip over the teeth above and below the slider.",
                "No pencil? A sliver of dry soap or a candle stub works the same way.",
                "Work the slider back a tooth, then forward — small strokes, growing longer.",
            ],
            prevention: [
                "Close zippers before washing — tumbling chews open teeth.",
                "A yearly pass of graphite keeps old metal zippers gliding.",
            ],
            proNote: "If teeth are torn off the tape or the slider is visibly bent open, a tailor can swap the slider in minutes for pennies.",
            artName: "repair_zipper"),
        CogRepairGuide(
            id: "fix-zipper-slack",
            title: "Zipper Won't Stay Closed",
            symptom: "It zips fine, then quietly reopens from the bottom.",
            why: "A worn slider has spread apart, so its channel no longer presses the teeth deep enough to hook each other.",
            mechID: "zipper",
            steps: [
                "Confirm the culprit: teeth intact, but the closed track pops open — that's slider spread.",
                "Move the slider to the very bottom of the track.",
                "With pliers, squeeze each rear corner of the slider VERY gently — a quarter squeeze.",
                "Test-zip. Repeat with another tiny squeeze until teeth hold.",
                "Stop at the first success — over-squeezing jams the slider entirely.",
            ],
            prevention: [
                "Don't yank a zipper around corners; guide the fabric with the other hand.",
            ],
            proNote: "Cast sliders can crack under pliers. On expensive jackets, let a repair shop fit a fresh slider instead.",
            artName: "repair_zipper2"),
        CogRepairGuide(
            id: "fix-hinge",
            title: "Squeaky Door Hinge",
            symptom: "Every swing of the door announces itself to the whole house.",
            why: "The hinge pin is a plain bearing — bare metal turning on bare metal. When its oil film dries out, the surfaces stick and slip, and that slip-stick is the squeak.",
            mechID: "camfollower",
            steps: [
                "Swing the door to find which hinge sings — a finger on each barrel feels the buzz.",
                "Lift the hinge pin halfway out with a screwdriver tap from below.",
                "Coat the pin with a drop of household oil or petroleum jelly.",
                "Tap it home and swing the door a dozen times to spread the film.",
                "Wipe the barrel — dust sticks to spare oil and grinds like paste.",
            ],
            prevention: [
                "A drop of oil per hinge every spring keeps doors silent for the year.",
            ],
            proNote: "A door that creaks AND sags needs its screws or frame looked at — that's carpentry, not lubrication.",
            artName: "repair_hinge"),
        CogRepairGuide(
            id: "fix-lock",
            title: "Sticky Front-Door Lock",
            symptom: "The key needs a wiggle-and-pray ritual before it turns.",
            why: "Dust and old grease clog the pin stacks, so the springs can't float the pins to the shear line. Oil makes this WORSE — it turns dust into glue.",
            mechID: "pinlock",
            steps: [
                "Scribble a soft pencil generously over both sides of the key's teeth.",
                "Slide the key fully in and out five or six times, twisting lightly.",
                "Repeat the graphite coat once more.",
                "For stubborn locks, puff powdered-graphite lock lubricant into the keyway.",
                "Never spray household oil into a cylinder — weeks later it gums solid.",
            ],
            prevention: [
                "A graphite refresh every season change keeps pins floating free.",
            ],
            proNote: "If the key turns but the bolt won't move, the trouble is in the door's mechanism case — locksmith territory.",
            artName: "repair_lock"),
        CogRepairGuide(
            id: "fix-chain",
            title: "Bike Chain Skipping",
            symptom: "Pedal hard and the drivetrain slips a beat with a clack.",
            why: "Chain and sprockets are a rack-and-pinion rolled into a loop: worn or dry links no longer match the teeth's pitch, so under load a link climbs the tooth and jumps.",
            mechID: "geartrain",
            steps: [
                "Wipe the chain with a rag until the links show metal.",
                "Drip one drop of chain lube into each roller, spinning the cranks slowly.",
                "Wipe the outside dry — outside oil only collects grit.",
                "Check wear: lift the chain at the front chainring's 3 o'clock tooth. If it lifts a full tooth clear, the chain is stretched.",
                "A stretched chain must be replaced before it re-carves the sprockets to match.",
            ],
            prevention: [
                "Lube monthly, and always after rain rides.",
            ],
            proNote: "Skipping that survives a fresh chain means the cassette teeth are already worn hooked — bike-shop job.",
            artName: "repair_chain"),
        CogRepairGuide(
            id: "fix-clock",
            title: "Wall Clock Runs Fast or Slow",
            symptom: "The old pendulum clock gains or loses minutes every day.",
            why: "A pendulum's beat depends only on its length. The rating nut under the bob raises or lowers it — a longer pendulum swings slower, a shorter one faster.",
            mechID: "escapement",
            steps: [
                "Note today's error against your phone: fast or slow, by how much.",
                "Find the small rating nut at the bottom of the pendulum bob.",
                "Running FAST: turn the nut to LOWER the bob — longer means slower.",
                "Running SLOW: raise the bob — shorter means faster.",
                "Half a turn per day of adjustment, then re-check tomorrow. Patience wins.",
            ],
            prevention: [
                "Keep the clock case level; a tilted clock beats unevenly and stops.",
            ],
            proNote: "If the tick and tock sound uneven (tick-tock… ticktock), the escapement needs professional putting 'in beat'.",
            artName: "repair_clock"),
        CogRepairGuide(
            id: "fix-handle",
            title: "Wobbly Door Handle",
            symptom: "The handle rattles loosely and turns further than it should.",
            why: "The handle grips its square spindle with a tiny grub screw. Every turn nudges the screw looser until the handle spins on the spindle instead of with it.",
            mechID: "rackpinion",
            steps: [
                "Look along the handle's neck for the small grub screw (often a hex socket).",
                "Hold the handle pressed toward the door plate.",
                "Tighten the grub screw firmly — snug, not gorilla-tight.",
                "If it keeps loosening, remove it, add a drop of thread-locker, refit.",
                "Check the two plate screws on the door face while you're there.",
            ],
            prevention: [
                "A ten-second screw check each year beats a handle in your hand.",
            ],
            proNote: "If the SPINDLE itself is worn round at the corners, replace the handle set — tightening can't cure geometry.",
            artName: "repair_handle"),
        CogRepairGuide(
            id: "fix-pen",
            title: "Click Pen Won't Click",
            symptom: "The button presses but the tip no longer locks out — or in.",
            why: "The rotating cam indexes on tiny plastic teeth. A grain of grit, a mis-seated spring, or a chewed cam tooth stops the half-step rotation that parks the tip.",
            mechID: "clickpen",
            steps: [
                "Unscrew the barrel and lay the parts out in order on a table.",
                "Blow through the barrel and wipe the cam and plunger clean.",
                "Check the spring sits centred on the cartridge collar, not cocked sideways.",
                "Reassemble, aligning the cam's teeth into the barrel's ribs before screwing shut.",
                "Ten test clicks: a healthy cam alternates crisply between parked and out.",
            ],
            prevention: [
                "Pocket lint is the great pen killer — cap end up helps.",
            ],
            proNote: "A cam with a sheared tooth is done — but the refill and spring live on in the next pen body.",
            artName: "repair_pen"),
        CogRepairGuide(
            id: "fix-cords",
            title: "Blind Cords Pull Unevenly",
            symptom: "One side of the venetian blind rises faster and the slats end up crooked.",
            why: "The lift cords run over separate pulleys like parallel block-and-tackle strands. When one cord jumps its pulley groove or tangles, the strands no longer share the load evenly.",
            mechID: "blocktackle",
            steps: [
                "Lower the blind fully so both cords go slack.",
                "Look into the headrail: each cord should sit in its own pulley groove.",
                "Flick a jumped cord back into its groove with a butter knife.",
                "Comb out any twist between the cords along their whole length.",
                "Raise and lower twice, slowly, letting the cords settle into their grooves.",
            ],
            prevention: [
                "Always raise blinds with a straight, gentle pull — sideways pulls derail cords.",
            ],
            proNote: "Frayed cords are a replacement job — and by law in many places, a cordless mechanism is the child-safe upgrade.",
            artName: "repair_cords"),
        CogRepairGuide(
            id: "fix-overwind",
            title: "Music Box Winds but Won't Play",
            symptom: "The key turns, the spring is tight, yet the tune never starts.",
            why: "The governor fan is the tempo brake — if it's blocked by dust or a bent blade, the whole train locks. 'Overwound' is a myth: a fully wound spring just waits for the train to free up.",
            mechID: "musicbox",
            steps: [
                "Never force the key further — the spring is fine; the blockage is downstream.",
                "Open the case and find the little spinning fan (governor).",
                "Blow the mechanism clean with a puff of air — dust bunnies stall governors.",
                "Nudge the fan gently with a toothpick; a healthy train starts immediately.",
                "If a fan blade is bent against its bracket, ease it straight with tweezers.",
            ],
            prevention: [
                "Keep the lid closed against dust, and wind fully but calmly.",
            ],
            proNote: "A tune that plays but drags or gallops needs governor adjustment — fine work best left to a repairer.",
            artName: "repair_overwind"),
    ]

    static func byID(_ id: String) -> CogRepairGuide? {
        all.first { $0.id == id }
    }
}
