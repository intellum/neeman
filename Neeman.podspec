Pod::Spec.new do |s|
  s.name         = "Neeman"
  s.version      = "0.2.3"
  s.summary      = "A framework for easily creating a hybrid app from a mobile friendly web app."

  s.description  = <<-DESC
The idea behind Neeman is to help you easily create a usable Hibrid app from an existing web app. 
It does this without getting in your way of adding additional native functionality. Try it out with your web app embeded in a native navigation stack. 
You can then see if you need to reimplement certain features natively. The best way to save development time and still maintain a beautify user experience 
is to keep your content rendered with HTML and implement your navigation natively.

## Getting Started
1. Create an Xcode project with the template best suiting your app.
2. Make one of your view controllers a WebViewController.
3. Set the **User Defined Runtime Attribute** `rootURLString` to the URL you which to display.
                   DESC

  s.homepage     = "https://intellum.com"


  s.license      = "MIT"

  s.author             = { "Stephen Williams" => "swilliams@intellum.com" }
  s.platform     = :ios
  s.platform     = :ios, "8.1"

  s.source       = { :git => "https://github.com/intellum/neeman.git", :tag => "#{s.version}" }
  s.source_files  = "Source/**/*.*"
  s.exclude_files = "Classes/Exclude"
  s.resources = "Resources/js/*.*", "Resources/Neeman.storyboard", "Resources/Assets.xcassets"
  s.frameworks = "WebKit", "SafariServices"

  s.requires_arc = true

end
