class Crawler

  attr_reader :options, :nodes, :node_description
  def initialize(options = {})
    @options = options
  end

  def get_nodes
    @nodes = find_nodes(taxonomy_file.xpath("//taxonomy").children)
  end

  def get_description
    @node_description = find_destination(destinations_file.xpath("//destination"), options[:id])
  end

  private

  def find_nodes(nodes, depth = 0, parent_id = nil)
    result = []
    nodes.each do |node|
      next unless node.name == "node" rescue binding.pry
      id = node.attributes["geo_id"].value
      name = node.children.map{|n| n.children.to_s if n.name == "node_name"}.compact.first
      result << {
        id: id,
        html_name: "#{'&nbsp;&nbsp;' * depth}#{name}".html_safe,
        name: name,
        depth: depth,
        parent_id: parent_id
      }
      child_nodes = node.children
      result << find_nodes(child_nodes, depth + 1, id)
    end
    result.flatten.compact
  end

  def find_destination(destinations, id = nil)
    return destinations.first.xpath("//history").text().gsub(/\n+/, '<br/>').html_safe if id.nil?
    destinations.each do |destination|
      if destination.attributes["atlas_id"].value == id
        return destination.text().gsub(/^\n+/, "&nbsp;&nbsp;&nbsp;").gsub(/\n+/, '<br/><br/>&nbsp;&nbsp;&nbsp;').html_safe
      else
      end
    end
    raise "Couldn't find a destination with ID: #{id}"
  end

  def taxonomy_name
    @taxonomy_name ||= taxonomy_file.xpath("//taxonomy").first

  end

  def taxonomy_file
    @taxonomy_file ||= File.open(Rails.root.join('lib', 'seed_files', 'taxonomy.xml').to_s) { |f| Nokogiri::XML(f) }
  end

  def destinations_file
    @destinations_file ||= File.open(Rails.root.join('lib', 'seed_files', 'destinations.xml').to_s) { |f| Nokogiri::XML(f) }
  end
end