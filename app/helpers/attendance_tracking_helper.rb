module AttendanceTrackingHelper
  include ContextMenusHelper 

  def user_options(selected_users)
    available_users = User.all.sort { |a,b| a.to_s.downcase <=> b.to_s.downcase }
    selected_users = available_users.map(&:id) if selected_users.blank?
    options_from_collection_for_select(available_users, :id, :name, selected_users)

  end

  def project_options(selected_projects)
    available_projects = Project.all.sort { |a,b| a.to_s.downcase <=> b.to_s.downcase }
    selected_projects = available_projects.map(&:id) if selected_projects.blank?
    selected_projects = selected_projects.map(&:to_i)
    project_tree_options_for_select(available_projects, :selected => selected_projects)
  end

  def options_for_period_select(value)
    options_for_select([[l(:label_all_time), 'all'],
                        [l(:label_today), 'today'],
                        [l(:label_yesterday), 'yesterday'],
                        [l(:label_this_week), 'current_week'],
                        [l(:label_last_week), 'last_week'],
                        [l(:label_last_n_weeks, 2), 'last_2_weeks'],
                        [l(:label_last_n_days, 7), '7_days'],
                        [l(:label_this_month), 'current_month'],
                        [l(:label_last_month), 'last_month'],
                        [l(:label_last_n_days, 30), '30_days'],
                        [l(:label_this_year), 'current_year']],
                        value)
  end

  def project_tree_options_for_select(projects, options = {})
    s = ''
    project_tree(projects) do |project, level|
      name_prefix = (level > 0 ? '&nbsp;' * 2 * level + '&#187; ' : '').html_safe
      tag_options = {:value => project.id}
      if project == options[:selected] || (options[:selected].respond_to?(:include?) && options[:selected].include?(project.id))
        tag_options[:selected] = 'selected'
      else
        tag_options[:selected] = nil
      end
      tag_options.merge!(yield(project)) if block_given?
      s << content_tag('option', name_prefix + h(project), tag_options)
    end
    s.html_safe
  end


end
