
firstproduct = File.new("stuff1.htm", "w")
endproduct = File.new("stuff2.htm", "w")
finalproduct = File.new("stuff3.htm", "w")

$bulk1 = "fourth.htm"
$bulk2 = "stuff1.htm"
$bulk3 = "stuff2.htm"

stuff = File.open($bulk1, File::RDWR).each_line{ |line|
    
  #remove this crap first

  if /[\n\r]/.match(line)
    if line !~ /(<[a\-zA\-Z\/][^>]*>)([\n])(<[a\-zA\-Z\/][^>]*>)/
      line.gsub!(/[\n\r]/, " ")
    end
  end
  
  line.gsub!(/<p class=rec>\(Commercial and Promotional\)<\/p>/, "")
  line.gsub!(/<p class=rec>\(Commercial\)<\/p>/, "")
  line.gsub!(/<p class=Type>\(Commercial and Promotional\)<\/p>/, "")
  line.gsub!(/<p class=Type>\(Commercial\)<\/p>/, "")
  
  line.gsub!(/(<p class=ArtistCross-ref55>)(.*?)(<\/p>)/, "")
  line.gsub!(/(<p class=Cross-Ref>)(.*?)(<\/p>)/, "")
  line.gsub!(/<br>\n/," ")
  line.gsub!(/<br>/," ")

  print line
    
    firstproduct.print line
 }

stuff2 = File.open($bulk2, File::RDWR).each_line{ |line|
  #replace wierd shit for amp
  line.gsub!(/&amp;/, "NPNNNNPN")
  line.gsub!(/&quot;/, "MPMMMMMPM")

  line.gsub!(/(<!--)(.*?)(-->)/, "")
  
  #get rid of first line
  line.gsub!(/(<html)(.*?)(<\/head>)/, "")


  #footnote
  line.gsub!(/(<p class=MsoNormal>)(\([^)]*\))(<\/p>)/, "<h4 class=footnote>" + "\\2" + "</h4>")
  line.gsub!(/(\n)(\([^)]*\))/, "<h4 class=footnote>" + "\\0" + "</h4>")

  #artist
  line.gsub!(/(<p class=ArtistHeading>)(.*?)(<\/p>)/, "</table>\n<table class=artist><p class=artist>" + "\\2" + "</p>")
  
  #type
  line.gsub!(/(<p class=Type>)(.*?)(<\/p>)/, "</div>\n<div class=type><p class=rec>" + "\\2" + "</p>")
  
  #record label
  line.gsub!(/(<p class=MsoNormal>)([A-Z0-9-&. ]*)/, "\n<p class=MsoNormal><h2 class=title>" + "\\2" + "</h2>")
  

  print line
    
    endproduct.print line
 }
 
 stuffagain = File.open($bulk3, File::RDWR).each_line{ |line|
   
   #replace wierd shit for amp
   line.gsub!(/NPNNNNPN/, "&amp;")
   line.gsub!(/MPMMMMMPM/, "&quot;")
   line.gsub!(/(<body)(.*?)(<\/table>)/, "")

   #record detail
   line.gsub!(/(<\/h2>)(\([^)]*\))/, "</h2>\n<h3 class=detail>" + "\\2" + "</h3>")
   
   #lastnotes
   line.gsub!(/( )(\([^)]*\))/, "<h4 class=footnote>" + "\\2" + "</h4>")
   
   #year
   line.gsub!(/(<\/span>)([0-9-'s]{2,})(<\/p>)/m, "\\1" + "<h5 class=year>" + "\\2" + "</h5>" + "\\3")
   line.gsub!(/(<\/span>)([0-9- ]{2,})(<h4 class=footnote>)/m, "\\1" + "<h5 class=year>" + "\\2" + "</h5>" + "\\3")

   #value
   line.gsub!(/(<\/span>)([0-9-]{1,})(<span)/m, "\\1" + "<h5 class=high>" +"\\2" + "</h5>" + "\\3")

   #split value
   line.gsub!(/(<h5 class=high>)([\d]{1,})-([\d]{1,})(<\/h5>)/m, "<h5 class=low>" + "\\2" + "</h5><h5 class=high>" + "\\3" + "</h5>")


   print line

     finalproduct.print line
  }
 

