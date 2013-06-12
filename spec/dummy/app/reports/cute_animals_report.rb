class CuteAnimalsReport < Dossier::Report
  HEADERS = -> { %w[family domestic group_id group_name name color cuteness gifs playful cost_new] }
  ROWS    = -> { [
    ["canine", true,  10, "foxes", "fennec",      "tan",    9, 896,  true,  1_000], 
    ["canine", true,  10, "foxes", "fire",        "orange", 0, 468,  false, 0], 
    ["canine", false, 10, "foxes", "arctic",      "white",  5, 108,  false, 2_500], 
    ["canine", false, 10, "foxes", "crab-eating", "brown",  3, 328,  false, 5_000], 
    ["canine", false, 10, "foxes", "red",         "orange", 5, 963,  false, 750], 
    ["canine", true,  15, "dog",   "shiba inu",   "tan",    7, 191,  true,  200], 
    ["canine", true,  15, "dog",   "labrador",    "varied", 5, 269,  true,  50], 
    ["canine", true,  15, "dog",   "beagle",      "mixed",  8, 917,  true,  25], 
    ["canine", true,  15, "dog",   "boxer",       "brown",  5, 14,   true,  50], 
    ["feline", false, 22, "tiger", "bengal",      "orange", 4, 184,  false, 100_000], 
    ["feline", false, 22, "tiger", "siberian",    "white",  5, 970,  false, 500_000],
    ["feline", false, 23, "lion",  "lion",        "tan",    5, 128,  false, 100_000], 
    ["feline", true,  219, "cat",  "short hair",  "varied", 6, 2062, true,  10],
    ["feline", true,  219, "cat",  "abyssinian",  "tan",    7, 125,  true,  20], 
    ["feline", true,  219, "cat",  "persian",     "varied", 6, 625,  false, 50], 
    ["feline", true,  219, "cat",  "wirehair",    "grey",   7, 758,  true , 75]
  ] }

  def initialize(*)
    super
    self.results = OpenStruct.new(headers: HEADERS.call, rows: ROWS.call)
  end

  def format_gifs(value)
    formatter.commafy_number(value)
  end

  def format_cost_new(value)
    formatter.number_to_dollars(value)
  end

  class Segmenter < Dossier::Segmenter
    segment :family
    segment :domestic, display_name: ->(row) { "#{row[:domestic] ? 'Domestic' : 'Wild'} #{row[:group_name]}" }
    segment :group,    display_name: :group_name, group_by: :group_id
  end
end

