# http://nokogiri.rubyforge.org/nokogiri/Nokogiri/XML/Builder.html
# http://wiki.hudson-ci.org/display/HUDSON/Post+build+task

require 'lib/job/build/commands'
require 'lib/api'

class XmlConfig
  include Commands
  
  def self.generate!(repo)  
    Nokogiri::XML::Builder.new do |xml|
      xml.project {
        xml.actions
        xml.logRotator {
          xml.daysToKeep 10
          xml.numToKeep 4
          xml.artifactDaysToKeep -1
          xml.artifactNumToKeep -1
        }
        xml.description
        xml.keepDependencies "false"
        xml.properties
        xml.scm(:class => "hudson.plugins.git.GitSCM") {
          xml.configVersion 1
          xml.remoteRepositories {
            xml.send('org.spearce.jgit.transport.RemoteConfig') {
              xml.string 'origin'
              xml.int 5
              xml.string 'fetch'
              xml.string '+refs/heads/*:refs/remotes/origin/*'
              xml.string 'receivepack'
              xml.string 'git-upload-pack'
              xml.string 'uploadpack'
              xml.string 'git-upload-pack'
              xml.string 'url'
              xml.string Api.config['github']['development']
              xml.string 'tagopt'
              xml.string
            }
          }
          xml.branches {
            xml.send('hudson.plugins.git.BranchSpec') {
              xml.name Api.remote(repo)
            }
          }
        xml.localBranch
        xml.mergeOptions
        xml.recursiveSubmodules 'false' 
        xml.doGenerateSubmoduleConfigurations 'false'
        xml.authorOrCommitter 'false' 
        xml.clean 'false'
        xml.wipeOutWorkspace 'false'
        xml.pruneBranches 'false'
        xml.buildChooser(:class=> "hudson.plugins.git.util.DefaultBuildChooser")
        xml.gitTool'Default'
        xml.submoduleCfg(:class=> "list")
        xml.relativeTargetDir
        xml.excludedRegions
        xml.excludedUsers
        } 
        xml.canRoam 'true'
        xml.disabled 'false'
        xml.blockBuildWhenUpstreamBuilding 'false'
        xml.triggers(:class=> "vector") {
          xml.send('hudson.triggers.SCMTrigger') {
            xml.spec '2 * * * *'
          }
        }
        xml.concurrentBuild 'false'
        xml.axes
        xml.builders {
          xml.send('hudson.tasks.Shell') {
            xml.command "#{Commands.build}"
          }
          xml.send('hudson.plugins.ruby.Ruby') {
            xml.command
          }
        }
        xml.publishers {
          xml.send('hudson.tasks.Mailer')
          xml.recipients
          xml.dontNotifyEveryUnstableBuild 'true'
          xml.sendToIndividuals 'true'
          xml.send('hudson.tasks.Mailer')
        }
        xml.buildWrappers
        xml.runSequentially 'false'
      }
    end.to_xml
  end

end

