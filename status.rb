def user_reg_count(uid)
  sql = "select count(*) from users where id in (select user_id from user_managers where employee_id=#{uid}) and login_count>0"
  one_result_query(sql)
end
def user_log_count(uid)
  sql = "select count(*) from users where id in (select user_id from user_managers where employee_id=#{uid}) and login_count>1"
  one_result_query(sql)
end
def one_result_query(sql)
  r = ActiveRecord::Base.connection.execute(sql)
  r.each do |row|
    return row[0]
  end
end

f = File.new("status.txt",'w')

gjpp = Taxon.find_by_name('国际品牌')
gnpp = Taxon.find_by_name('国内品牌')
f.puts "产品数：" + Product.active.count.to_s + " (有报价：#{Product.active.price_between(100,10000).count})"
f.puts "     - 国际品牌: #{Product.active.in_taxon(gjpp).count}, 有报价: #{Product.active.in_taxon(gjpp).price_between(100,10000).count}"
f.puts "     - 国内品牌: #{Product.active.in_taxon(gnpp).count}, 有报价：#{Product.active.in_taxon(gnpp).price_between(100,10000).count}"
f.puts "----------------"
f.puts "客户数: " + User.count.to_s + "(有登录过：#{User.all(:conditions => 'login_count>0' ).count.to_s}, 活动客户：#{User.all(:conditions => 'login_count>1' ).count.to_s})"

um = UserManager.all(:group => 'employee_id', :select => 'count(*) as cnt, employee_id')
tot = 0
um.each do |u|
  usr = User.find_by_id(u.employee_id)
  if usr
    f.puts "        " + User.find_by_id(u.employee_id).display_name + "\t" + u.cnt.to_s \
      + " (有登录过:#{user_reg_count(u.employee_id)}, 活动客户:#{user_log_count(u.employee_id)})"
    tot = tot + u.cnt.to_i
  end
end
f.puts "        tot: " + tot.to_s

f.puts "----------------"
