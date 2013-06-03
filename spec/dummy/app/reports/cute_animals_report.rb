class CuteAnimalsReport < Dossier::Report
  HEADERS = -> { %w[family domestic group_id group_name name color cuteness gifs playful] }
  ROWS    = -> { [
    ["canine", true,  10, "foxes", "fennec",      "tan",    9, 896, true], 
    ["canine", true,  10, "foxes", "fire",        "orange", 0, 468, false], 
    ["canine", false, 10, "foxes", "arctic",      "white",  5, 108, false], 
    ["canine", false, 10, "foxes", "crab-eating", "brown",  3, 328, false], 
    ["canine", false, 10, "foxes", "red",         "orange", 5, 963, false], 
    ["canine", true,  15, "dog",   "shiba inu",   "tan",    7, 191, true], 
    ["canine", true,  15, "dog",   "labrador",    "varied", 5, 269, true], 
    ["canine", true,  15, "dog",   "beagle",      "mixed",  8, 917, true], 
    ["canine", true,  15, "dog",   "boxer",       "brown",  5, 14,  true], 
    ["feline", false, 22, "tiger", "bengal",      "orange", 4, 184, false], 
    ["feline", false, 22, "tiger", "siberian",    "white",  5, 970, false],
    ["feline", false, 23, "lion",  "lion",        "tan",    5, 128, false], 
    ["feline", true,  25, "cat",   "short hair",  "varied", 6, 262, true],
    ["feline", true,  25, "cat",   "abyssinian",  "tan",    7, 125, true], 
    ["feline", true,  25, "cat",   "persian",     "varied", 6, 625, false], 
    ["feline", true,  25, "cat",   "wirehair",    "grey",   7, 758, true]
  ] }

  def results
    @results ||= OpenStruct.new(headers: HEADERS.call, rows: ROWS.call)
  end
  alias :raw_results :results

  class Segmenter
    segment :family
    segment :domestic, display_name: ->(row) { "#{row[:domestic] ? 'Domestic' : 'Wild'} #{row[:group_name]}" }
    segment :group,    display_name: :group_name, group_by: :group_id
  end
end

