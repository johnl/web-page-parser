# -*- coding: utf-8 -*-
require 'spec_helper'
include WebPageParser

describe TheInterceptPageParserFactory do
  before do
    @valid_urls = [
                   'https://firstlook.org/theintercept/2014/10/22/canada-proclaiming-war-12-years-shocked-someone-attacked-soldiers/',
                   'https://firstlook.org/theintercept/2014/10/31/block-boat-work-middle/',
                   'https://firstlook.org/theintercept/2014/10/31/block-boat-work-middle'
                  ]
    @invalid_urls = [
                     'https://firstlook.org/theintercept/document/2014/10/30/hacking-team-rcs-9-0-changelog/',
                     'https://firstlook.org/theintercept/froomkin/',
                     'https://firstlook.org/theintercept/staff/jeremy-scahill/'
                    ]
  end

  it "should detect intercept articles from the url" do
    @valid_urls.each do |url|
      TheInterceptPageParserFactory.can_parse?(:url => url).should be_true
    end
  end

  it "should ignore pages with the wrong url format" do
    @invalid_urls.each do |url|
      TheInterceptPageParserFactory.can_parse?(:url => url).should be_nil
    end
  end
  
end

describe TheInterceptPageParserV1 do

  describe 'when parsing the canada at war article' do
    before do
      @valid_options = {
                        :url => 'https://firstlook.org/theintercept/2014/10/22/canada-proclaiming-war-12-years-shocked-someone-attacked-soldiers/',
                        :page => File.read('spec/fixtures/theintercept/canada-proclaiming-war-12-years-shocked-someone-attacked-soldiers.html'),
                        :valid_hash => '6110428997aafee4873fd2cd2dbc6c03'
                       }
      @pa = TheInterceptPageParserV1.new(@valid_options)
      
    end

    it 'should parse the title' do
      @pa.title.should == "Canada, At War For 13 Years, Shocked That 'A Terrorist' Attacked Its Soldiers"
    end

    it 'should parse the content' do
      @pa.content[1].should == 'TORONTO – In Quebec on Monday, two Canadian soldiers were hit by a car driven by Martin Couture-Rouleau, a 25-year-old Canadian who, as The Globe and Mail reported, “converted to Islam recently and called himself Ahmad Rouleau.” One of the soldiers died, as did Couture-Rouleau when he was shot by police upon apprehension after allegedly brandishing a large knife. Police speculated that the incident was deliberate, alleging the driver waited for two hours before hitting the soldiers, one of whom was wearing a uniform. The incident took place in the parking lot of a shopping mall 30 miles southeast of Montreal, “a few kilometres from the Collège militaire royal de Saint-Jean, the military academy operated by the Department of National Defence.”'
       @pa.content[5].should == 'First, Canada has spent the last 13 years proclaiming itself a nation at war. It actively participated in the invasion and occupation of Afghanistan and was an enthusiastic partner in some of the most extremist War on Terror abuses perpetrated by the U.S. Earlier this month, the Prime Minister revealed, with the support of a large majority of Canadians, that “Canada is poised to go to war in Iraq, as [he] announced plans in Parliament [] to send CF-18 fighter jets for up to six months to battle Islamic extremists.” Just yesterday, Canadian Defence Minister Rob Nicholson flamboyantly appeared at the airfield in Alberta from which the fighter jets left for Iraq and stood tall as he issued the standard Churchillian war rhetoric about the noble fight against evil.'
      @pa.content[16].should == 'Even when a definition is agreed upon, the rhetoric of “terror” is applied both selectively and inconsistently. In the mainstream American media, the “terrorist” label is usually reserved for those opposed to the policies of the U.S. and its allies. By contrast, some acts of violence that constitute terrorism under most definitions are not identified as such — for instance, the massacre of over 2000 Palestinian civilians in the Beirut refugee camps in 1982 or the killings of more than 3000 civilians in Nicaragua by “contra” rebels during the 1980s, or the genocide that took the lives of at least a half million Rwandans in 1994. At the opposite end of the spectrum, some actions that do not qualify as terrorism are labeled as such — that would include attacks by Hamas, Hezbollah or ISIS, for instance, against uniformed soldiers on duty.'
      @pa.content[23].should == 'UPDATE II: In that brilliant essay I referenced above, published just three days ago in The New York Times, Professor Tomis Kapitan made this point:'
      @pa.content.last.should == 'That point is so simple and, as he said, “obvious” that I have a hard time understanding what could account for some commentators conflating the two other than a willful desire to mislead.'
      @pa.content.size.should == 26
      @pa.hash.should == @valid_options[:valid_hash]
    end

    it 'should parse the date in UTC' do
      @pa.date.should == DateTime.parse('22nd October 2014, 08:56:26')
      @pa.date.zone.should == '+00:00'
    end

  end

  describe 'when parsing the pentagon missionary article' do
    before do
      @valid_options = {
                        :url => 'https://theintercept.com/2015/10/26/pentagon-missionary-spies-christian-ngo-front-for-north-korea-espionage/',
                        :page => File.read('spec/fixtures/theintercept/pentagon-missionary.html'),
                        :valid_hash => 'aa8a59955cc0c783f782c5c13701c71d'
                       }
      @pa = TheInterceptPageParserV1.new(@valid_options)
    end

    it 'should parse the title' do
      @pa.title.should == "U.S. Military Used Christian NGO as Front for North Korea Espionage"
    end

    it 'should parse the content' do
      @pa.content[0].should == 'ON MAY 10, 2007, in the East Room of the White House, President George W. Bush presided over a ceremony honoring the nation’s most accomplished community service leaders. Among those collecting a President’s Volunteer Service Award that afternoon was Kay Hiramine, the Colorado-based founder of a multimillion-dollar humanitarian organization.'
       @pa.content[13].should == 'HISG WAS ESTABLISHED shortly after 9/11, when Hiramine led a group of three friends in creating a humanitarian organization that they hoped could provide disaster relief and sustainable development in poor and war-torn countries around the world, according to the organization’s incorporation documents.'
       @pa.content[83].should == 'This report makes reference to a donation from Working Partners Foundation to Catholic Relief Services, based on Working Partners Foundation’s tax filings. Catholic Relief Services, which conducted a review after publication, said its own records contained no indication it received money from Working Partners Foundation or HISG.'
       @pa.content.last.should == 'Top photo: U.S. President George W. Bush with Kay Hiramine prior to presenting him with a President’s Volunteer Service Award on May 10, 2007, in the East Room of the White House (photo flipped). '
       @pa.content.size.should == 86
       @pa.hash.should == @valid_options[:valid_hash]
    end

    it 'should parse the date in UTC' do
      @pa.date.should == DateTime.parse('Oct. 26 2015 15:05:22')
      @pa.date.zone.should == '+00:00'
    end

  end

end
