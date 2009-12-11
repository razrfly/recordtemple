require '../config/environment'
require 'rubygems'  
require 'hpricot'  
require 'open-uri'
require 'rubygems'
require 'amatch'
include Amatch


def get_stuff(doc)
  
  #finalproduct = File.new("chuck.sql", "w")
  
  #finalproduct.print "INSERT INTO `rockin_records` (artist, record_type, label, detail, price_low, price_high, the_year)\n"
  
  (doc/"table.artist").each do |post|
    #puts "<artist>" + post.inner_html.strip + "</artist>"
    artist = (post/"p.artist").inner_html
    artist_fix = artist.gsub(/'/, "''")
    #puts "Artist: " + artist.inner_html
    artist_fix2 = artist_fix.gsub(/<[a-zA-Z\/][^>]*>/, "")
    artist_fix3 = artist_fix2.gsub(/&quot;/, '"')
    artist_fix4 = artist_fix3.gsub(/&amp;/, "&")
    artist_fix5 = artist_fix4.gsub(/&nbsp;/, "")
    artist_fix6 = artist_fix5.gsub(/<.*?>/, "")
    
    (post/"div.type").each do |post2|
      type = (post2/"p.rec").inner_html
      type_fix = type.gsub(/&#8211;/, "-")
      type_fix2 = type_fix.gsub(/<[a-zA-Z\/][^>]*>/, "")
      type_fix3 = type_fix2.gsub(/&nbsp;/, "")
      type_fix4 = type_fix3.gsub(/&quot;/, "''")
      
      #4 most common formats
      singles7 = 'Singles: 7-inch'
      lps = 'LPs: 10/12-inch'
      seveneights = 'Singles: 78 rpm'
      psleeves = 'Picture Sleeves'
      eps = 'EPs: 7-inch'
      singles12 = 'Singles: 12-inch'
      
      m = Levenshtein.new(type_fix4)
      if m.match(singles7) < 2 
        format = singles7
      elsif m.match(lps) < 2 
        format = lps
      elsif m.match(seveneights) < 2 
        format = seveneights
      elsif m.match(psleeves) < 2 
        format = psleeves
      elsif m.match(eps) < 2 
        format = eps
      elsif m.match(singles12) < 2 
        format = singles12
      else
        format = type_fix4
      end  
      
      
      
      #puts "Type: " + type.inner_html
      
      (post2/"p.MsoNormal").each do |post3|
        record = (post3/"h2.title").inner_html.chomp
        detail = (post3/"h3.detail").inner_html
        footnotes = (post3/"h4.footnote").inner_html
        #recordno = /\d{3,}/.match(detail)
        #detail_no_tags = detail.gsub!(/<[a-zA-Z\/][^>]*>/, "")
        
        footnotes_fix = footnotes.gsub(/(\()(.*)(\))/, "\\2")
        footnotes_fix1 = footnotes_fix.gsub(/'/, "''")
        footnotes_fix2 = footnotes_fix1.gsub(/&quot;/, '"')
        footnotes_fix3 = footnotes_fix2.gsub(/&nbsp;/, "")
        footnotes_fix4 = footnotes_fix3.gsub(/&amp;/, "&")
        footnotes_fix5 = footnotes_fix4.gsub(/&#8211;/, "")
        footnotes_fix6 = footnotes_fix5.gsub(/[.]{2,}/, "")
        footnotes_fix7 = footnotes_fix6.gsub(/<[a-zA-Z\/][^>]*>/, "")
        

        #remove trailing white space
        record_fix = record.gsub(/[ \t]+$/, "")
        #remove tags
        record_fix2 = record_fix.gsub(/<[a-zA-Z\/][^>]*>/, "")
        record_fix3 = record_fix2.gsub(/&amp;/, "&")
        record_fix4 = record_fix3.gsub(/&quot;/, "''")
        label = record_fix4.gsub(/&nbsp;/, "")
        #remove tags
        detail_tags = detail.gsub(/<[a-zA-Z\/][^>]*>/, "")
        #remove parenthesis
        detail_song_title = detail_tags.gsub(/(\()(.*)(\))/, "\\2")
        detail_fix = detail_song_title.gsub(/'/, "''")
        detail_fix2 = detail_fix.gsub(/&quot;/, '"')
        detail_fix3 = detail_fix2.gsub(/&nbsp;/, "")
        detail_fix4 = detail_fix3.gsub(/&amp;/, "&")
        detail_fix5 = detail_fix4.gsub(/&#8211;/, "")
        detail_fix6 = detail_fix5.gsub(/[.]{2,}/, "")
        #detail_rec_no = detail.gsub!(/([A-Z0-9\-\/]{2,10})/, "\\1")
        low = (post3/"h5.low").inner_html
        high = (post3/"h5.high").inner_html
        year = (post3/"h5.year").inner_html
        year_fix = year.gsub(/'/, "''")
        year_fix2 = year_fix.gsub(/[ \t]+$/, "")

        
        #reverse values if value is price is nil
        if low == ""
          low = year_fix2.gsub(/([0-9]*)-([0-9]*)/, "\\1")
          high = year_fix2.gsub(/([0-9]*)-([0-9]*)/, "\\2")
          year_fix2 = ""
        end
        

        if year_fix2 != ""
          if year_fix2 =~ /(')([0-9]{2})(s)/
            year_fix3 = year_fix2.gsub(/[^0-9]/, "")
            year1 = "19" + year_fix3.chop + "0"
            year2 = "19" + year_fix3.chop + "9"
          elsif year_fix2 =~ /([0-9]{2})-([0-9]{2})/
            year1 = year_fix2.gsub(/([0-9]{2})(-)([0-9]{2})/, "19" + "\\1")
            year2 = year_fix2.gsub(/([0-9]{2})(-)([0-9]{2})/, "19" + "\\3")
          elsif year_fix2 =~ /^0/
            year1 = "20" + year_fix2
            year2 = "20" + year_fix2
          elsif year_fix2 =~ /[0-9]{4}/
            year1 = year_fix2
            year2 = year_fix2
          else
            year1 = "19" + year_fix2
            year2 = "19" + year_fix2
          end
        else
          year1 = year_fix2
          year2 = year_fix2
        end
        
        
        #sql
        #puts "'" + artist.inner_html + "', '" + type.inner_html + "', " + record.inner_html + "', '" + detail.inner_html + "', " + low.inner_html + ", " + high.inner_html + ", " + year.inner_html
        #print "'" + artist + "', '" + type + "', " + record + "', '" + detail_rec_no + "', '" + detail_songs + "', " + low + ", " + high + ", " + year + "\n"
        if artist_fix5 != "DELETE, Crap"
          print "VALUES ('" + artist_fix6 + "', '" + format + "', '" + label + "', '" + detail_fix6 + "', '" + footnotes_fix7 + "', '" + low + "', '" + high + "', '" + year1 + "', '" + year2 + "');\n"
        
          #finalproduct.print "INSERT INTO `prices` (artist, format, label, detail, footnote, pricelow, pricehigh, yearbegin, yearend) VALUES ('" + artist_fix5 + "', '" + format + "', '" + label + "', '" + detail_fix6 + "', '" + footnotes_fix7 + "', '" + low + "', '" + high + "', '" + year1 + "', '" + year2 + "');\n"
            c = Price.new
            c.artist = artist_fix6
            c.format = format
            c.label = label
            c.detail = detail_fix6
            c.footnote = footnotes_fix7
            c.pricelow = low
            c.pricehigh = high
            c.yearbegin = year1
            c.yearend = year2
            c.save
            
            d = Bubble.new
            d.low = low
            d.high = high
            d.price_id = c.id
            d.save

        end
      end
    end
    
    
    
    
  end
end

# Run the script
$rubyist_home = "stuff3.htm"
doc = Hpricot(open($rubyist_home))
get_stuff doc