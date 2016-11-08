module Documentation::CategoriesHelper

  def option_groups_from_collection_for_select(collection, group_method, group_label_method, option_key_method, option_value_method, selected_key = nil)
    collection.inject("") do |options_for_select, group|
      group_label_string = eval("group.#{group_label_method}")
      options_for_select += "<optgroup label=\"#{html_escape(group_label_string)}\">"
      options_for_select += options_from_collection_for_select(eval("group.#{group_method}"), option_key_method, option_value_method, selected_key)
      options_for_select += '</optgroup>'
    end
  end

  def tree_option_groups_from_collection_for_select(collection, group_method, group_label_method, option_key_method, option_value_method, selected_key = nil)
    collection.map do |group|
      option_tags = options_from_collection_for_select(
          group.send(group_method), option_key_method, option_value_method, selected_key  )

      content_tag(:optgroup, option_tags, id: group.send(option_key_method), label: group.send(group_label_method) )
    end.join.html_safe
  end
end
