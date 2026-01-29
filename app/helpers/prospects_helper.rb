module ProspectsHelper
  def prospect_stage_options(include_all: false)
    options = Prospect.stages.keys.map { |s| [ s.humanize, s ] }
    include_all ? [ [ "All Stages", "" ] ] + options : options
  end

  def prospect_source_options(include_all: false)
    options = Prospect.sources.keys.map { |s| [ s.humanize, s ] }
    include_all ? [ [ "All Sources", "" ] ] + options : options
  end
end
