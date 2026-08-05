import SwiftUI

// The full mechanism library: 16 movements across 4 wings.
enum MechLibrary {

    static func byID(_ id: String) -> MechanismSpec? {
        all.first { $0.id == id }
    }

    static func wing(_ wing: MechWing) -> [MechanismSpec] {
        all.filter { $0.wing == wing }
    }

    static let all: [MechanismSpec] = [

        // MARK: Around the House

        MechanismSpec(
            id: "zipper",
            name: "Zipper Slider",
            wing: .house,
            tagline: "A tiny wedge that weaves teeth together.",
            era: "Patented 1913 · Gideon Sundback",
            history: "Early 'clasp lockers' jammed constantly. Swedish engineer Gideon Sundback cracked the problem in 1913 with cup-shaped teeth and a slider whose hidden wedge angles them together. The B.F. Goodrich company coined the snappy name 'zipper' for its rubber boots a decade later, and the fastener conquered the world.",
            facts: [
                "The teeth never touch the slider's outer shell — all the work is done by the wedge inside.",
                "A zipper only opens tooth by tooth, which is why it holds even under strong sideways pull.",
                "Modern zip teeth are stamped to tolerances finer than a tenth of a millimetre.",
            ],
            spotIt: [
                "Jackets, jeans and boots",
                "Backpacks, tents and luggage",
                "Pencil cases and sofa cushions",
            ],
            parts: [
                MechPartSpec(id: "leftrow", name: "Left Teeth", role: "One row of identical hooks on its fabric tape.", anchor: CGPoint(x: 36, y: 16), explode: CGVector(dx: -14, dy: 0)),
                MechPartSpec(id: "rightrow", name: "Right Teeth", role: "The mirror row — offset by half a tooth.", anchor: CGPoint(x: 64, y: 16), explode: CGVector(dx: 14, dy: 0)),
                MechPartSpec(id: "wedge", name: "Wedge", role: "The hidden heart: angles the rows into each other.", anchor: CGPoint(x: 42, y: 50), explode: CGVector(dx: 0, dy: -16)),
                MechPartSpec(id: "slider", name: "Slider Body", role: "Guides both tapes through its Y-shaped channel.", anchor: CGPoint(x: 62, y: 52), explode: CGVector(dx: 17, dy: 6)),
                MechPartSpec(id: "tab", name: "Pull Tab", role: "Your handle — it also locks the slider on jeans.", anchor: CGPoint(x: 57, y: 70), explode: CGVector(dx: 18, dy: 14)),
            ],
            stages: [
                MechStageSpec(id: 1, title: "Two rows of hooks", caption: "Each tape carries identical teeth, offset by half a step — like two halves of a handshake waiting to happen.", highlight: ["leftrow", "rightrow"], phase: 0...1),
                MechStageSpec(id: 2, title: "The hidden wedge", caption: "Inside the slider a Y-shaped wedge tilts each tooth just enough to hook its neighbour from the other side.", highlight: ["wedge"], phase: 0...0.5),
                MechStageSpec(id: 3, title: "Gliding shut", caption: "As the slider climbs, its narrowing channel presses the angled teeth together — they interlock one by one.", highlight: ["slider"], phase: 0...0.5),
                MechStageSpec(id: 4, title: "Prying open", caption: "Pulled the other way, the wedge's point pries the meshed teeth apart — one at a time, never all at once.", highlight: ["slider", "wedge"], phase: 0.5...1),
            ],
            cycleSeconds: 7,
            draw: mechDrawZipper),

        MechanismSpec(
            id: "pinlock",
            name: "Pin Tumbler Lock",
            wing: .house,
            tagline: "Five little pins guard the door.",
            era: "Ancient Egypt · perfected 1861 by Linus Yale Jr.",
            history: "Wooden pin locks guarded Egyptian granaries four thousand years ago. In 1861 Linus Yale Jr. shrank the idea into the compact brass cylinder we still use: spring-loaded pin stacks that block a rotating plug until exactly the right key lines every stack up at the shear line.",
            facts: [
                "Each pin stack has two pins — the cut between them must land exactly on the shear line.",
                "A typical five-pin lock has over a million theoretical key combinations.",
                "The 'click' you feel when a key slides in is each pin dropping into its valley on the blade.",
            ],
            spotIt: [
                "Front doors and padlocks",
                "Desk drawers and lockers",
                "Bicycle locks and mailboxes",
            ],
            parts: [
                MechPartSpec(id: "housing", name: "Housing", role: "The fixed outer body, holding springs and driver pins.", anchor: CGPoint(x: 20, y: 24), explode: CGVector(dx: 0, dy: -18)),
                MechPartSpec(id: "springs", name: "Springs", role: "Push every pin stack down into the plug.", anchor: CGPoint(x: 42, y: 27), explode: CGVector(dx: 0, dy: -12)),
                MechPartSpec(id: "driverpins", name: "Driver Pins", role: "Uniform steel pins that straddle the shear line and block rotation.", anchor: CGPoint(x: 52, y: 36), explode: CGVector(dx: 0, dy: -7)),
                MechPartSpec(id: "plug", name: "Plug", role: "The rotating cylinder your key slides into.", anchor: CGPoint(x: 20, y: 52), explode: CGVector(dx: 0, dy: 10)),
                MechPartSpec(id: "keypins", name: "Key Pins", role: "Different lengths — they read the key's valleys.", anchor: CGPoint(x: 62, y: 48), explode: CGVector(dx: 0, dy: 16)),
                MechPartSpec(id: "key", name: "Key", role: "Its bitting lifts each stack to exactly the right height.", anchor: CGPoint(x: 12, y: 62), explode: CGVector(dx: -18, dy: 12)),
                MechPartSpec(id: "shear", name: "Shear Line", role: "The magic boundary where plug meets housing.", anchor: CGPoint(x: 84, y: 42), explode: CGVector(dx: 0, dy: 0)),
            ],
            stages: [
                MechStageSpec(id: 1, title: "Blocked by default", caption: "Springs press the pin stacks down so the driver pins cross into the plug — the cylinder simply cannot turn.", highlight: ["driverpins", "springs"], phase: 0...0.06),
                MechStageSpec(id: 2, title: "The key reads in", caption: "Each valley on the blade lifts its own pin stack. Deeper cut, lower lift — five little measurements at once.", highlight: ["key", "keypins"], phase: 0.02...0.45),
                MechStageSpec(id: 3, title: "The shear line", caption: "With the right key, every cut between key pin and driver pin lands exactly on the gap between plug and housing.", highlight: ["shear", "driverpins", "keypins"], phase: 0.45...0.62),
                MechStageSpec(id: 4, title: "Free to turn", caption: "Nothing crosses the boundary any more — the plug rotates and works the bolt. A wrong key jams at step three.", highlight: ["plug", "key"], phase: 0.6...0.95),
            ],
            cycleSeconds: 8,
            draw: mechDrawPinLock),

        MechanismSpec(
            id: "clickpen",
            name: "Click Pen",
            wing: .house,
            tagline: "A cam ballet in every click.",
            era: "1950s · the ballpoint boom",
            history: "When ballpoints became cheap in the 1950s, makers raced to hide the ink tip without a cap. The winner was the rotating cam: a plunger with slanted teeth that twists a toothed cylinder a little with every press, alternately parking it in a deep slot (tip out) or a shallow one (tip in). The satisfying click is the cam snapping home.",
            facts: [
                "Each press rotates the cam by exactly half a tooth — two presses make one full step.",
                "The spring never stops pushing; the cam's resting slot decides whether the tip shows.",
                "Engineers call this a 'rotating cam indexing mechanism' — the same trick lives in retractable screwdrivers.",
            ],
            spotIt: [
                "Retractable ballpoint pens",
                "Some retractable utility knives",
                "Push-button spray mops",
            ],
            parts: [
                MechPartSpec(id: "barrel", name: "Barrel", role: "The guide tube with internal ribs the cam rides on.", anchor: CGPoint(x: 62, y: 26), explode: CGVector(dx: 16, dy: 0)),
                MechPartSpec(id: "button", name: "Button", role: "Where your thumb pushes.", anchor: CGPoint(x: 55, y: 8), explode: CGVector(dx: 0, dy: -14)),
                MechPartSpec(id: "plunger", name: "Plunger", role: "Slanted teeth on its base twist the cam as it presses down.", anchor: CGPoint(x: 42, y: 22), explode: CGVector(dx: -14, dy: -6)),
                MechPartSpec(id: "cam", name: "Rotating Cam", role: "Turns a half-tooth per click and parks deep or shallow.", anchor: CGPoint(x: 58, y: 38), explode: CGVector(dx: 14, dy: -2)),
                MechPartSpec(id: "spring", name: "Return Spring", role: "Pushes the whole works back up after every press.", anchor: CGPoint(x: 42, y: 54), explode: CGVector(dx: -14, dy: 6)),
                MechPartSpec(id: "cartridge", name: "Ink Cartridge", role: "Rides on the cam; its tip pokes out when the cam parks low.", anchor: CGPoint(x: 55, y: 74), explode: CGVector(dx: 0, dy: 16)),
            ],
            stages: [
                MechStageSpec(id: 1, title: "Press down", caption: "Your thumb drives the plunger straight down, compressing the spring and shoving the cam below the barrel's ribs.", highlight: ["button", "plunger"], phase: 0...0.22),
                MechStageSpec(id: 2, title: "The twist", caption: "Free of the ribs, the cam's slanted teeth slide along the plunger's teeth — the cam rotates half a step.", highlight: ["cam"], phase: 0.12...0.3),
                MechStageSpec(id: 3, title: "Parked out", caption: "Released, the spring pushes the cam up — but rotated, it now lands in a shallow slot, holding the tip out.", highlight: ["cam", "cartridge"], phase: 0.22...0.5),
                MechStageSpec(id: 4, title: "Click to retract", caption: "The next press twists the cam another half-step to a deep slot — the spring pulls the cartridge safely home.", highlight: ["spring", "cartridge"], phase: 0.5...1),
            ],
            cycleSeconds: 6,
            draw: mechDrawClickPen),

        MechanismSpec(
            id: "musicbox",
            name: "Music Box",
            wing: .house,
            tagline: "A song written in brass pins.",
            era: "Switzerland · 1796, Antoine Favre",
            history: "Geneva watchmaker Antoine Favre replaced chiming bells with tuned steel teeth in 1796, and the pocket music box was born. A clockwork spring turns a brass cylinder studded with pins; each pin plucks one tooth of a steel comb at exactly the right beat. The whole score is frozen into the pin pattern.",
            facts: [
                "Longer comb teeth play lower notes — the comb is literally a metal keyboard.",
                "The spinning governor fan is an air brake: it keeps the tempo steady as the spring winds down.",
                "One cylinder can hold several tunes — sliding it sideways lines up a different set of pins.",
            ],
            spotIt: [
                "Jewellery boxes and snow globes",
                "Wind-up children's mobiles",
                "Collector's musical automata",
            ],
            parts: [
                MechPartSpec(id: "bed", name: "Bedplate", role: "The wooden base that also acts as a soundboard.", anchor: CGPoint(x: 14, y: 82), explode: CGVector(dx: 0, dy: 16)),
                MechPartSpec(id: "drum", name: "Mainspring Drum", role: "A wound spiral spring — the music's power source.", anchor: CGPoint(x: 13, y: 56), explode: CGVector(dx: -16, dy: 8)),
                MechPartSpec(id: "gearing", name: "Drive Gears", role: "Carry the spring's power to cylinder and governor.", anchor: CGPoint(x: 38, y: 74), explode: CGVector(dx: -6, dy: 14)),
                MechPartSpec(id: "cylinder", name: "Pinned Cylinder", role: "The score: every pin is one note at one beat.", anchor: CGPoint(x: 45, y: 42), explode: CGVector(dx: 0, dy: -16)),
                MechPartSpec(id: "comb", name: "Steel Comb", role: "Tuned teeth, long to short — bass to treble.", anchor: CGPoint(x: 86, y: 40), explode: CGVector(dx: 16, dy: 0)),
                MechPartSpec(id: "governor", name: "Governor Fan", role: "Air resistance keeps the tune from racing.", anchor: CGPoint(x: 62, y: 20), explode: CGVector(dx: 6, dy: -16)),
            ],
            stages: [
                MechStageSpec(id: 1, title: "Wound-up power", caption: "A coiled mainspring stores your winding turns and releases them slowly through the gear train.", highlight: ["drum", "gearing"], phase: 0...1),
                MechStageSpec(id: 2, title: "The brass score", caption: "The cylinder turns once per verse. Every pin on its surface is a note, placed at its exact beat.", highlight: ["cylinder"], phase: 0...1),
                MechStageSpec(id: 3, title: "Teeth that sing", caption: "Each pin lifts a comb tooth and lets it snap back — the tooth rings at its own pitch, long teeth low, short teeth high.", highlight: ["comb"], phase: 0...1),
                MechStageSpec(id: 4, title: "Keeping tempo", caption: "The governor fan spins fast and drags on the air — a gentle brake that keeps the melody steady to the last turn.", highlight: ["governor"], phase: 0...1),
            ],
            cycleSeconds: 8,
            draw: mechDrawMusicBox),

        // MARK: Gear Works

        MechanismSpec(
            id: "geartrain",
            name: "Spur Gear Pair",
            wing: .gears,
            tagline: "Where all rotation begins.",
            era: "Antikythera mechanism · 2nd century BC",
            history: "Toothed wheels are older than written engineering: the Antikythera mechanism, a Greek astronomical calculator from around 150 BC, already used dozens of precisely cut bronze gears. The rule they obey has never changed — teeth mesh, so speeds trade against turning force in exact whole-number ratios.",
            facts: [
                "Meshed gears always turn in opposite directions — add an idler gear to keep the direction.",
                "The 24:12 pair here doubles speed but halves torque; swap driver and driven to do the reverse.",
                "Real tooth flanks are involute curves, so the push between teeth stays perfectly smooth.",
            ],
            spotIt: [
                "Hand egg-beaters and drills",
                "Bicycle hub gears",
                "Clocks, mills and gearboxes everywhere",
            ],
            parts: [
                MechPartSpec(id: "driver", name: "Driver Gear", role: "24 teeth — the input that power arrives on.", anchor: CGPoint(x: 18, y: 32), explode: CGVector(dx: -16, dy: -6)),
                MechPartSpec(id: "driven", name: "Driven Gear", role: "12 teeth — spins twice as fast, the other way.", anchor: CGPoint(x: 76, y: 36), explode: CGVector(dx: 16, dy: -6)),
                MechPartSpec(id: "shafts", name: "Shafts", role: "Fixed axles each gear spins on.", anchor: CGPoint(x: 46, y: 64), explode: CGVector(dx: 0, dy: -18)),
                MechPartSpec(id: "frame", name: "Frame", role: "Holds the shafts at exactly meshing distance.", anchor: CGPoint(x: 80, y: 54), explode: CGVector(dx: 0, dy: 18)),
            ],
            stages: [
                MechStageSpec(id: 1, title: "The driver", caption: "Power arrives on the big wheel. Watch one marked hole — it passes the top once per turn.", highlight: ["driver"], phase: 0...1),
                MechStageSpec(id: 2, title: "Teeth in mesh", caption: "At the meeting point, tooth pushes on tooth like a chain of tiny levers. No slipping, ever.", highlight: ["driver", "driven"], phase: 0...1),
                MechStageSpec(id: 3, title: "Two for one", caption: "24 teeth drive 12: the small gear must make two full turns for every one of the big gear — and turns opposite.", highlight: ["driven"], phase: 0...1),
                MechStageSpec(id: 4, title: "Exact spacing", caption: "The frame holds both shafts so tooth tips overlap roots by just the right amount. Too far apart and they'd skip.", highlight: ["frame", "shafts"], phase: 0...1),
            ],
            cycleSeconds: 6,
            draw: mechDrawGearTrain),

        MechanismSpec(
            id: "rackpinion",
            name: "Rack and Pinion",
            wing: .gears,
            tagline: "A gear unrolled into a straight line.",
            era: "Steering standard since the 1930s",
            history: "Unroll a gear's circumference into a straight strip and you get a rack. Mesh a round pinion with it and rotation becomes straight-line travel — instantly and precisely. Cars adopted rack-and-pinion steering in the 1930s because the driver feels exactly what the wheels do, with no slack.",
            facts: [
                "Every degree of pinion turn moves the rack the same fixed distance — that's why steering feels precise.",
                "Funicular railways climb mountains on giant racks bolted between the rails.",
                "Your camera's zoom ring often drives the lens with a miniature rack and pinion.",
            ],
            spotIt: [
                "Car steering systems",
                "Cog railways up steep mountains",
                "Microscope focus knobs and sliding gates",
            ],
            parts: [
                MechPartSpec(id: "pinion", name: "Pinion", role: "The round gear — your rotational input.", anchor: CGPoint(x: 36, y: 30), explode: CGVector(dx: 0, dy: -16)),
                MechPartSpec(id: "rack", name: "Rack", role: "A toothed bar — rotation becomes straight travel.", anchor: CGPoint(x: 22, y: 62), explode: CGVector(dx: 0, dy: 10)),
                MechPartSpec(id: "rails", name: "Guide Rails", role: "Let the rack slide but never twist.", anchor: CGPoint(x: 16, y: 70), explode: CGVector(dx: 0, dy: 16)),
                MechPartSpec(id: "shaft", name: "Steering Shaft", role: "Carries the driver's turn down to the pinion.", anchor: CGPoint(x: 74, y: 20), explode: CGVector(dx: 16, dy: -10)),
            ],
            stages: [
                MechStageSpec(id: 1, title: "Turn the pinion", caption: "The wheel above twists the pinion back and forth — pure rotation so far.", highlight: ["shaft", "pinion"], phase: 0...1),
                MechStageSpec(id: 2, title: "Mesh with the bar", caption: "Pinion teeth engage the rack exactly like a second gear — one that happens to be perfectly straight.", highlight: ["pinion", "rack"], phase: 0...1),
                MechStageSpec(id: 3, title: "Straight-line output", caption: "The rack slides left and right in exact proportion to the turn. No slack, no delay.", highlight: ["rack"], phase: 0...1),
                MechStageSpec(id: 4, title: "Guided travel", caption: "Rails keep the rack pressed into mesh while it slides — sideways force goes into the frame, not the teeth.", highlight: ["rails"], phase: 0...1),
            ],
            cycleSeconds: 7,
            draw: mechDrawRackPinion),

        MechanismSpec(
            id: "wormgear",
            name: "Worm Gear",
            wing: .gears,
            tagline: "A screw that tames speed.",
            era: "Archimedes · 3rd century BC",
            history: "Archimedes is credited with pairing a screw to a toothed wheel to haul enormous loads with one hand. The worm's single thread advances the wheel just one tooth per full revolution — a huge reduction in one compact step, with a bonus: the wheel usually can't drive the worm backwards, so the load holds itself.",
            facts: [
                "This 24-tooth wheel needs 24 worm turns for one revolution — a 24:1 reduction in one stage.",
                "Most worm drives self-lock: guitar strings stay in tune because the tuning peg can't back-drive.",
                "The sliding contact makes worm drives quiet but warm — big ones need oil baths.",
            ],
            spotIt: [
                "Guitar and violin tuning pegs",
                "Hose clamps around pipes",
                "Lift winches and heavy sluice gates",
            ],
            parts: [
                MechPartSpec(id: "inshaft", name: "Input Crank", role: "Fast, easy turns go in here.", anchor: CGPoint(x: 12, y: 22), explode: CGVector(dx: -16, dy: -8)),
                MechPartSpec(id: "worm", name: "Worm Screw", role: "One spiral thread — each turn pushes one tooth along.", anchor: CGPoint(x: 52, y: 24), explode: CGVector(dx: 0, dy: -16)),
                MechPartSpec(id: "wheel", name: "Worm Wheel", role: "Creeps around slowly with multiplied force.", anchor: CGPoint(x: 30, y: 68), explode: CGVector(dx: 0, dy: 14)),
                MechPartSpec(id: "outshaft", name: "Output Shaft", role: "Slow, strong rotation leaves here.", anchor: CGPoint(x: 60, y: 62), explode: CGVector(dx: 16, dy: 10)),
            ],
            stages: [
                MechStageSpec(id: 1, title: "Spin the screw", caption: "The crank whirls the worm easily — it's just a screw thread spinning in place.", highlight: ["inshaft", "worm"], phase: 0...1),
                MechStageSpec(id: 2, title: "One tooth per turn", caption: "Each full revolution of the thread nudges the wheel along by exactly one tooth. Count the crawl.", highlight: ["worm", "wheel"], phase: 0...1),
                MechStageSpec(id: 3, title: "24 to 1", caption: "Twenty-four fast, easy turns become one slow, powerful one. Speed traded for force at a fixed exchange rate.", highlight: ["wheel"], phase: 0...1),
                MechStageSpec(id: 4, title: "No backing up", caption: "Push on the wheel and the thread just binds — friction wins. The load can't unwind itself.", highlight: ["worm", "outshaft"], phase: 0...1),
            ],
            cycleSeconds: 9,
            draw: mechDrawWormGear),

        MechanismSpec(
            id: "planetary",
            name: "Planetary Gearset",
            wing: .gears,
            tagline: "A tiny solar system of gears.",
            era: "1781 · Watt's sun-and-planet",
            history: "James Watt patented the sun-and-planet drive in 1781 to dodge a rival's crank patent, and the layout proved a marvel: a central sun, orbiting planets, a surrounding ring and a carrier — four members sharing load on multiple teeth at once. Hold a different member and you get a different ratio from the same compact set.",
            facts: [
                "Load is shared by all three planets at once, so planetary sets are small yet immensely strong.",
                "Hold the ring, drive the sun: the carrier turns slowly the same way — the ratio shown here is 3.5:1.",
                "Automatic gearboxes stack several planetary sets and simply brake different members to shift.",
            ],
            spotIt: [
                "Automatic car transmissions",
                "Cordless drill gearboxes",
                "Bicycle hub gears and wind turbines",
            ],
            parts: [
                MechPartSpec(id: "sun", name: "Sun Gear", role: "The centre of the system — input in this setup.", anchor: CGPoint(x: 42, y: 48), explode: CGVector(dx: -14, dy: -14)),
                MechPartSpec(id: "planets", name: "Planet Gears", role: "Spin on their own pins while orbiting the sun.", anchor: CGPoint(x: 68, y: 32), explode: CGVector(dx: 14, dy: -14)),
                MechPartSpec(id: "ring", name: "Ring Gear", role: "Internal teeth all around — held fixed here.", anchor: CGPoint(x: 78, y: 16), explode: CGVector(dx: 0, dy: 0)),
                MechPartSpec(id: "carrier", name: "Carrier", role: "Links the planet pins — the slow, strong output.", anchor: CGPoint(x: 58, y: 66), explode: CGVector(dx: 0, dy: 20)),
            ],
            stages: [
                MechStageSpec(id: 1, title: "The sun spins", caption: "Power enters at the golden centre gear, meshing with all three planets at once.", highlight: ["sun"], phase: 0...1),
                MechStageSpec(id: 2, title: "Planets orbit", caption: "Each planet rolls between sun and ring — spinning on its pin while the whole trio circles the centre.", highlight: ["planets"], phase: 0...1),
                MechStageSpec(id: 3, title: "The ring stands still", caption: "The fixed internal ring is the track the planets walk around. Hold a different member, get a different ratio.", highlight: ["ring"], phase: 0...1),
                MechStageSpec(id: 4, title: "Carrier output", caption: "The arms linking the planet pins turn slowly and smoothly — 3.5 sun turns for each carrier turn.", highlight: ["carrier"], phase: 0...1),
            ],
            cycleSeconds: 9,
            draw: mechDrawPlanetary),

        // MARK: Cranks & Linkages

        MechanismSpec(
            id: "crankslider",
            name: "Crank and Slider",
            wing: .linkages,
            tagline: "Round and round becomes back and forth.",
            era: "Al-Jazari · 1206",
            history: "The engineer Al-Jazari described crank-and-rod machines for raising water in 1206, and the mechanism went on to power the industrial world in both directions: steam engines used sliding pistons to spin wheels, while pumps and saws used spinning wheels to slide pistons. It remains the beating heart of nearly every car engine.",
            facts: [
                "The slider moves fastest at mid-stroke and pauses for an instant at each end — feel the rhythm.",
                "Those end pauses are called 'dead centres'; engines carry a flywheel to coast through them.",
                "Run it either way: spin the crank to pump, or push the piston to spin — same geometry.",
            ],
            spotIt: [
                "Car engine pistons and crankshafts",
                "Hand water pumps and air compressors",
                "Jigsaw blades and sewing machine needles",
            ],
            parts: [
                MechPartSpec(id: "crank", name: "Crank Wheel", role: "The rotating input with an offset pin.", anchor: CGPoint(x: 24, y: 74), explode: CGVector(dx: -16, dy: 8)),
                MechPartSpec(id: "rod", name: "Connecting Rod", role: "Ties the spinning pin to the sliding piston.", anchor: CGPoint(x: 48, y: 42), explode: CGVector(dx: 0, dy: -20)),
                MechPartSpec(id: "piston", name: "Slider", role: "Travels a dead-straight line, twice per turn.", anchor: CGPoint(x: 76, y: 70), explode: CGVector(dx: 16, dy: 8)),
                MechPartSpec(id: "guide", name: "Guide", role: "Rails that permit sliding and forbid everything else.", anchor: CGPoint(x: 82, y: 48), explode: CGVector(dx: 0, dy: -16)),
            ],
            stages: [
                MechStageSpec(id: 1, title: "The offset pin", caption: "The crank pin rides a circle. That offset from the centre is the whole secret — it defines the stroke length.", highlight: ["crank"], phase: 0...1),
                MechStageSpec(id: 2, title: "The rod swings", caption: "The connecting rod follows the pin with its top and drags its bottom along the line — tilting side to side as it works.", highlight: ["rod"], phase: 0...1),
                MechStageSpec(id: 3, title: "Straight-line stroke", caption: "Caught between rod and rails, the slider sweeps back and forth — one full round trip per crank turn.", highlight: ["piston", "guide"], phase: 0...1),
                MechStageSpec(id: 4, title: "The full dance", caption: "Watch all three together: circle, swing, line. Reverse the flow of power and a pump becomes an engine.", highlight: [], phase: 0...1),
            ],
            cycleSeconds: 6,
            draw: mechDrawCrankSlider),

        MechanismSpec(
            id: "camfollower",
            name: "Cam and Follower",
            wing: .linkages,
            tagline: "Motion sculpted in metal.",
            era: "Hellenistic automata · 3rd century BC",
            history: "Greek automata makers carved rotating profiles to poke levers at chosen moments, effectively programming machines in bronze. The cam is exactly that: its outline is a graph of lift against time, wrapped around a shaft. Car engines still open every valve this way, millions of times a minute across the world.",
            facts: [
                "Read the egg shape as a graph: distance from the shaft centre equals follower height at that instant.",
                "A car camshaft opens each valve in about five thousandths of a second at highway speed.",
                "Music-box cylinders are just many tiny cams in a row — each pin a single programmed 'lift'.",
            ],
            spotIt: [
                "Engine valve trains",
                "Automatic soap dispensers and toys",
                "Old looms and clockwork automata",
            ],
            parts: [
                MechPartSpec(id: "cam", name: "Cam", role: "The egg-shaped profile — a programme carved in metal.", anchor: CGPoint(x: 64, y: 74), explode: CGVector(dx: 0, dy: 16)),
                MechPartSpec(id: "follower", name: "Follower", role: "Roller and stem that ride the profile up and down.", anchor: CGPoint(x: 40, y: 42), explode: CGVector(dx: -16, dy: -8)),
                MechPartSpec(id: "spring", name: "Return Springs", role: "Keep the roller pressed onto the cam at all times.", anchor: CGPoint(x: 62, y: 24), explode: CGVector(dx: -14, dy: 6)),
                MechPartSpec(id: "frame", name: "Guide Frame", role: "Constrains the stem to pure vertical motion.", anchor: CGPoint(x: 42, y: 16), explode: CGVector(dx: 16, dy: -6)),
            ],
            stages: [
                MechStageSpec(id: 1, title: "A shape with intent", caption: "The cam is no accident — every bump and dwell on its edge is a motion someone designed, frozen into steel.", highlight: ["cam"], phase: 0...1),
                MechStageSpec(id: 2, title: "Riding the profile", caption: "The roller follows the edge exactly: rising over the lobe, resting on the round base circle.", highlight: ["follower"], phase: 0...1),
                MechStageSpec(id: 3, title: "Never lose contact", caption: "Springs chase the follower down the far side of the lobe — lose contact at speed and the motion 'floats' and chatters.", highlight: ["spring"], phase: 0...1),
                MechStageSpec(id: 4, title: "One clean output", caption: "Spin in, programmed lift out: rise, dwell, fall, rest — repeated identically every single revolution.", highlight: [], phase: 0...1),
            ],
            cycleSeconds: 6,
            draw: mechDrawCamFollower),

        MechanismSpec(
            id: "ratchet",
            name: "Ratchet and Pawl",
            wing: .linkages,
            tagline: "The mechanism that never gives back.",
            era: "Medieval windlasses & clock winders",
            history: "Medieval builders hoisting stone learned to love the click of a pawl dropping behind a saw tooth: the load could rise a notch at a time and never crash back. The ratchet became the keeper of one-way motion — in clock winders, capstans, jacks and every socket wrench that clicks freely one way and drives hard the other.",
            facts: [
                "The tooth shape does the thinking: a long slope lets the pawl slide over, a steep face stops it dead.",
                "That clicking when you pedal backwards? A freewheel ratchet inside your bicycle hub.",
                "Two pawls do the work here: one drives the wheel forward, one holds every notch that's been won.",
            ],
            spotIt: [
                "Socket wrenches and cable ties",
                "Bicycle freewheels",
                "Winches, jacks and seatbelt retractors",
            ],
            parts: [
                MechPartSpec(id: "wheel", name: "Ratchet Wheel", role: "Saw teeth: gentle slope one way, hard wall the other.", anchor: CGPoint(x: 34, y: 40), explode: CGVector(dx: -16, dy: -8)),
                MechPartSpec(id: "lever", name: "Drive Lever", role: "Your handle — swings back and forth.", anchor: CGPoint(x: 82, y: 64), explode: CGVector(dx: 16, dy: 10)),
                MechPartSpec(id: "drivepawl", name: "Drive Pawl", role: "Pushes a tooth on the power stroke, hops over on the return.", anchor: CGPoint(x: 72, y: 40), explode: CGVector(dx: 12, dy: -14)),
                MechPartSpec(id: "holdpawl", name: "Holding Pawl", role: "Spring-loaded guard that forbids any backward turn.", anchor: CGPoint(x: 22, y: 26), explode: CGVector(dx: -6, dy: -18)),
                MechPartSpec(id: "frame", name: "Frame", role: "Anchors the wheel shaft and the holding pawl.", anchor: CGPoint(x: 66, y: 88), explode: CGVector(dx: 0, dy: 18)),
            ],
            stages: [
                MechStageSpec(id: 1, title: "The power stroke", caption: "The lever swings and its pawl presses square against a tooth's steep face — the wheel must follow.", highlight: ["lever", "wheel"], phase: 0.05...0.45),
                MechStageSpec(id: 2, title: "Click — the free ride", caption: "On the way back the pawl meets only gentle slopes: it lifts, skips over the tip and drops behind the next tooth.", highlight: ["drivepawl"], phase: 0.55...0.95),
                MechStageSpec(id: 3, title: "The silent guard", caption: "All the while the holding pawl leans on the wheel — any attempt to slip backwards jams against it instantly.", highlight: ["holdpawl"], phase: 0.45...1),
                MechStageSpec(id: 4, title: "Won, notch by notch", caption: "Swing after swing, the wheel only ever gains ground. Progress is banked one click at a time.", highlight: [], phase: 0...1),
            ],
            cycleSeconds: 5,
            draw: mechDrawRatchet),

        MechanismSpec(
            id: "fourbar",
            name: "Wiper Linkage",
            wing: .linkages,
            tagline: "One motor, two perfect arcs.",
            era: "1920s · powered wiper systems",
            history: "Early drivers cleared rain by hand crank. Powered wipers of the 1920s hid a lovely piece of geometry under the cowl: a four-bar linkage. A small motor spins a crank; a coupler rod converts that circle into a to-and-fro swing of a rocker arm, and a parallel link makes a second blade copy the first exactly. No gears, no slipping — just four hinged bars.",
            facts: [
                "Four-bar linkages are the workhorses of mechanism design — knee joints in robots use the same idea.",
                "The crank turns full circles while the rocker only swings: that's called a crank-rocker linkage.",
                "The parallel connecting link is why both blades stay perfectly in step in the rain.",
            ],
            spotIt: [
                "Windscreen wipers",
                "Locomotive side rods and pedal bins",
                "Folding lamps and excavator arms",
            ],
            parts: [
                MechPartSpec(id: "crank", name: "Motor Crank", role: "Spins continuously — the only powered part.", anchor: CGPoint(x: 16, y: 86), explode: CGVector(dx: -14, dy: 10)),
                MechPartSpec(id: "coupler", name: "Coupler Rod", role: "Turns the crank's circle into a swing.", anchor: CGPoint(x: 38, y: 62), explode: CGVector(dx: 0, dy: 16)),
                MechPartSpec(id: "rockers", name: "Rocker Arms", role: "Pivot on the body and carry the blades.", anchor: CGPoint(x: 56, y: 70), explode: CGVector(dx: 0, dy: -6)),
                MechPartSpec(id: "link", name: "Parallel Link", role: "Makes the second arm mirror the first.", anchor: CGPoint(x: 68, y: 56), explode: CGVector(dx: 0, dy: -14)),
                MechPartSpec(id: "blades", name: "Wiper Blades", role: "Sweep matched arcs across the glass.", anchor: CGPoint(x: 86, y: 34), explode: CGVector(dx: 8, dy: -18)),
            ],
            stages: [
                MechStageSpec(id: 1, title: "The spinning crank", caption: "The motor doesn't reverse — it just turns. Everything else is geometry's job.", highlight: ["crank"], phase: 0...1),
                MechStageSpec(id: 2, title: "Circle into swing", caption: "The coupler rod pushes and pulls the rocker as the crank pin circles — a full turn becomes one wipe and return.", highlight: ["coupler"], phase: 0...1),
                MechStageSpec(id: 3, title: "Arms in step", caption: "A parallel link ties the two rockers together, so both arms swing through identical angles at identical times.", highlight: ["rockers", "link"], phase: 0...1),
                MechStageSpec(id: 4, title: "Clean sweep", caption: "At the glass, the blades trace matching arcs — smooth at the ends because the crank geometry slows them naturally.", highlight: ["blades"], phase: 0...1),
            ],
            cycleSeconds: 6,
            draw: mechDrawFourBar),

        // MARK: Great Machines

        MechanismSpec(
            id: "escapement",
            name: "Anchor Escapement",
            wing: .machines,
            tagline: "The heartbeat of every clock.",
            era: "1657 · Huygens & the pendulum clock",
            history: "A clock's problem is not making a wheel turn — it's making it turn slowly and evenly. The escapement is the answer: an anchor rocked by a pendulum alternately blocks and frees a toothed wheel, letting it 'escape' half a tooth per swing. Christiaan Huygens' pendulum clock of 1657 cut daily errors from minutes to seconds and gave the world its tick-tock.",
            facts: [
                "The tick and the tock are the two pallets landing — a real clock beats twice per pendulum swing.",
                "Each escaping tooth gives the pendulum a tiny push, replacing energy lost to friction and air.",
                "A one-metre pendulum swings once per second regardless of how wide it swings — that's the magic.",
            ],
            spotIt: [
                "Grandfather and wall clocks",
                "Mechanical wristwatches (a balance wheel replaces the pendulum)",
                "Metronomes and kitchen timers",
            ],
            parts: [
                MechPartSpec(id: "pendulum", name: "Pendulum", role: "The timekeeper — its length alone sets the beat.", anchor: CGPoint(x: 36, y: 82), explode: CGVector(dx: 0, dy: 18)),
                MechPartSpec(id: "anchor", name: "Anchor", role: "Rocks with the pendulum; its pallets catch and release.", anchor: CGPoint(x: 68, y: 30), explode: CGVector(dx: 0, dy: -14)),
                MechPartSpec(id: "escapewheel", name: "Escape Wheel", role: "Driven wheel that may only advance tooth by tooth.", anchor: CGPoint(x: 66, y: 58), explode: CGVector(dx: 14, dy: 8)),
                MechPartSpec(id: "drive", name: "Drive Weight", role: "Gravity power, fed up the cord to the wheel.", anchor: CGPoint(x: 22, y: 72), explode: CGVector(dx: -18, dy: 0)),
                MechPartSpec(id: "frame", name: "Clock Frame", role: "Holds pivots in line — precision lives here.", anchor: CGPoint(x: 42, y: 13), explode: CGVector(dx: 0, dy: -16)),
            ],
            stages: [
                MechStageSpec(id: 1, title: "A steady beat", caption: "The pendulum swings at a rate fixed by its length — nature's free metronome, accurate for hours.", highlight: ["pendulum"], phase: 0...1),
                MechStageSpec(id: 2, title: "Catch and release", caption: "The anchor rocks with the pendulum: as one pallet lifts clear of the wheel, the other drops into its path.", highlight: ["anchor"], phase: 0...1),
                MechStageSpec(id: 3, title: "Escape, half a tooth", caption: "Between catches the wheel leaps forward — exactly half a tooth — then slams to a stop. Tick. Tock.", highlight: ["escapewheel"], phase: 0.1...0.9),
                MechStageSpec(id: 4, title: "Paying the pendulum", caption: "Each escaping tooth flicks the anchor, feeding the pendulum a whisper of energy so it never runs down mid-day.", highlight: ["drive", "pendulum"], phase: 0...1),
            ],
            cycleSeconds: 6,
            draw: mechDrawEscapement),

        MechanismSpec(
            id: "fourstroke",
            name: "Four-Stroke Engine",
            wing: .machines,
            tagline: "Suck, squeeze, bang, blow.",
            era: "1876 · Nikolaus Otto",
            history: "Nikolaus Otto's 1876 engine tamed combustion into a four-act play, one stroke per act: draw in the mixture, squeeze it tight, ignite it to shove the piston down, then sweep the burnt gas out. Two full crank turns per single power stroke — and a rhythm so effective it still powers most of the world's vehicles.",
            facts: [
                "Only one stroke in four delivers power — the flywheel's stored spin carries the engine through the other three.",
                "Mechanics remember the cycle as 'suck, squeeze, bang, blow'.",
                "At motorway pace this play repeats about twenty times per second in every cylinder.",
            ],
            spotIt: [
                "Cars, motorbikes and lawnmowers",
                "Portable generators",
                "Small aircraft and go-karts",
            ],
            parts: [
                MechPartSpec(id: "cylinder", name: "Cylinder", role: "The combustion chamber's strong walls.", anchor: CGPoint(x: 68, y: 40), explode: CGVector(dx: 18, dy: -4)),
                MechPartSpec(id: "charge", name: "The Charge", role: "Air-fuel mixture: blue in, fire, grey out.", anchor: CGPoint(x: 50, y: 32), explode: CGVector(dx: 0, dy: 0)),
                MechPartSpec(id: "intakevalve", name: "Intake Valve", role: "Opens to admit fresh mixture.", anchor: CGPoint(x: 34, y: 14), explode: CGVector(dx: -16, dy: -10)),
                MechPartSpec(id: "exhaustvalve", name: "Exhaust Valve", role: "Opens to release burnt gas.", anchor: CGPoint(x: 66, y: 14), explode: CGVector(dx: 16, dy: -10)),
                MechPartSpec(id: "spark", name: "Spark Plug", role: "One precise spark ignites each charge.", anchor: CGPoint(x: 50, y: 9), explode: CGVector(dx: 0, dy: -16)),
                MechPartSpec(id: "piston", name: "Piston", role: "Takes the explosion's push.", anchor: CGPoint(x: 36, y: 54), explode: CGVector(dx: -18, dy: 0)),
                MechPartSpec(id: "rod", name: "Connecting Rod", role: "Hands the push down to the crank.", anchor: CGPoint(x: 58, y: 62), explode: CGVector(dx: 0, dy: 14)),
                MechPartSpec(id: "crank", name: "Crank & Flywheel", role: "Turns strokes into smooth spin.", anchor: CGPoint(x: 64, y: 82), explode: CGVector(dx: 0, dy: 18)),
            ],
            stages: [
                MechStageSpec(id: 1, title: "Intake — suck", caption: "The piston slides down with the intake valve open, drawing a fresh blue charge of air and fuel into the cylinder.", highlight: ["intakevalve", "charge", "piston"], phase: 0...0.27),
                MechStageSpec(id: 2, title: "Compression — squeeze", caption: "Valves shut. The piston climbs, squeezing the charge to a fraction of its volume — packed with energy.", highlight: ["piston", "charge"], phase: 0.25...0.5),
                MechStageSpec(id: 3, title: "Power — bang", caption: "The spark fires. The burning charge expands violently, driving the piston down — the only stroke that pays.", highlight: ["spark", "piston", "rod"], phase: 0.48...0.75),
                MechStageSpec(id: 4, title: "Exhaust — blow", caption: "The exhaust valve opens and the rising piston sweeps the spent grey gas out, clearing the stage for the next act.", highlight: ["exhaustvalve", "piston"], phase: 0.73...1),
            ],
            cycleSeconds: 8,
            draw: mechDrawFourStroke),

        MechanismSpec(
            id: "steamwheel",
            name: "Locomotive Drive",
            wing: .machines,
            tagline: "The rods that made railways run.",
            era: "1829 · Stephenson's Rocket",
            history: "Stephenson's Rocket of 1829 fixed the pattern every steam locomotive followed: steam shoves a piston, a crosshead keeps its rod honest, a main rod cranks a driving wheel, and side rods chain the other drivers to it so every wheel pushes the rail together. The whole spectacle runs in the open — engineering as public theatre.",
            facts: [
                "The two cylinder cranks are set 90° apart, so one is always mid-push when the other is at a dead end.",
                "Side rods force every driving wheel to turn in perfect step — more grip without slipping.",
                "The hypnotic rise and dip of the rods gave steam engines their famous galloping look.",
            ],
            spotIt: [
                "Preserved steam locomotives",
                "Railway museums worldwide",
                "Vintage traction engines at county fairs",
            ],
            parts: [
                MechPartSpec(id: "piston", name: "Cylinder & Piston", role: "Steam pressure becomes a straight push.", anchor: CGPoint(x: 9, y: 52), explode: CGVector(dx: -16, dy: 0)),
                MechPartSpec(id: "crosshead", name: "Crosshead", role: "Slides on guide bars, keeping the piston rod straight.", anchor: CGPoint(x: 22, y: 50), explode: CGVector(dx: 0, dy: -14)),
                MechPartSpec(id: "mainrod", name: "Main Rod", role: "Carries the push to the first driver's crank pin.", anchor: CGPoint(x: 34, y: 70), explode: CGVector(dx: 8, dy: -20)),
                MechPartSpec(id: "siderod", name: "Side Rod", role: "Couples all driving wheels into one team.", anchor: CGPoint(x: 66, y: 54), explode: CGVector(dx: 0, dy: 20)),
                MechPartSpec(id: "wheels", name: "Driving Wheels", role: "Grip the rail and turn push into travel.", anchor: CGPoint(x: 82, y: 72), explode: CGVector(dx: 0, dy: 16)),
                MechPartSpec(id: "framebar", name: "Frame & Rail", role: "The locomotive's spine above, the road below.", anchor: CGPoint(x: 12, y: 44), explode: CGVector(dx: 0, dy: -18)),
            ],
            stages: [
                MechStageSpec(id: 1, title: "Steam pushes", caption: "High-pressure steam drives the piston back and forth in its cylinder — pure straight-line muscle.", highlight: ["piston"], phase: 0...1),
                MechStageSpec(id: 2, title: "Kept honest", caption: "The crosshead slides between guide bars so the piston rod can't buckle when the main rod angles off it.", highlight: ["crosshead", "mainrod"], phase: 0...1),
                MechStageSpec(id: 3, title: "Cranking the driver", caption: "The main rod grabs a pin offset on the wheel — every push and pull becomes another half-turn. It's a crank-slider in reverse.", highlight: ["mainrod", "wheels"], phase: 0...1),
                MechStageSpec(id: 4, title: "Wheels in step", caption: "Side rods link every driver's pin, so all wheels push together — watch the rod float in its circular glide.", highlight: ["siderod"], phase: 0...1),
            ],
            cycleSeconds: 6,
            draw: mechDrawSteamWheel),

        MechanismSpec(
            id: "blocktackle",
            name: "Block and Tackle",
            wing: .machines,
            tagline: "Trade distance for strength.",
            era: "Archimedes · compound pulleys, 3rd century BC",
            history: "Legend says Archimedes hauled a loaded ship along the shore single-handed using compound pulleys. The trick is beautifully simple: every rope strand supporting the moving block carries a share of the load. Two strands, half the effort — you just pull twice as much rope. Sailors rigged tackles all over their ships and never looked back.",
            facts: [
                "Count the ropes holding the lower block — that number is your force multiplier.",
                "Nothing is free: lifting one metre with two strands means hauling in two metres of rope.",
                "The word 'tackle' comes from the age of sail, when a ship carried dozens of these rigs.",
            ],
            spotIt: [
                "Sailing boat mainsheets",
                "Engine hoists in garages",
                "Theatre fly systems, cranes and gyms",
            ],
            parts: [
                MechPartSpec(id: "beam", name: "Beam", role: "Solid anchor point overhead.", anchor: CGPoint(x: 26, y: 8), explode: CGVector(dx: 0, dy: -14)),
                MechPartSpec(id: "upperblock", name: "Upper Block", role: "Fixed pulley — changes the rope's direction.", anchor: CGPoint(x: 64, y: 14), explode: CGVector(dx: 14, dy: -8)),
                MechPartSpec(id: "lowerblock", name: "Lower Block", role: "Moving pulley — rides up with the load.", anchor: CGPoint(x: 64, y: 50), explode: CGVector(dx: 14, dy: 8)),
                MechPartSpec(id: "rope", name: "Rope", role: "One line woven through both blocks.", anchor: CGPoint(x: 74, y: 32), explode: CGVector(dx: -10, dy: 0)),
                MechPartSpec(id: "load", name: "Load", role: "The crate that suddenly feels half as heavy.", anchor: CGPoint(x: 30, y: 68), explode: CGVector(dx: 0, dy: 16)),
            ],
            stages: [
                MechStageSpec(id: 1, title: "One rope, woven", caption: "A single line ties off at the top, loops under the moving block, and comes back over the fixed pulley to your hand.", highlight: ["rope"], phase: 0...1),
                MechStageSpec(id: 2, title: "Strands share the load", caption: "Two rope strands now hold the lower block — each carries only half the crate's weight. That's the entire secret.", highlight: ["upperblock", "lowerblock"], phase: 0...1),
                MechStageSpec(id: 3, title: "Pull far, lift strong", caption: "Haul two metres of rope and the crate rises one. Half the force, twice the distance — energy stays perfectly balanced.", highlight: ["rope", "load"], phase: 0...0.5),
                MechStageSpec(id: 4, title: "Ease it down", caption: "Let the rope run back and gravity lowers the load just as gently — the same trade in reverse.", highlight: ["load"], phase: 0.5...1),
            ],
            cycleSeconds: 8,
            draw: mechDrawBlockTackle),
    ]
}
