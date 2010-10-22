class UpdateTaxons


end

ps = []
ps << {:brand=>'Brand1', :model=>'Model1', :system=>'GSM', :taxons=>'taxon1'}
ps << {:brand=>'Brand1', :model=>'Model2', :system=>'GSM', :taxons=>'taxon1'}
ps << {:brand=>'Brand1', :model=>'Model3', :system=>'3G', :taxons=>'taxon2'}
ps << {:brand=>'Brand1', :model=>'Model4', :system=>'3G', :taxons=>'taxon2'}
ps << {:brand=>'Brand1', :model=>'Model5', :system=>'ZS', :taxons=>'taxon3'}
ps << {:brand=>'Brand1', :model=>'Model6', :system=>'ZS', :taxons=>'taxon3'}

ut = UpdateTaxons.new
ps.each do |p|
  ut.update(p)
end
