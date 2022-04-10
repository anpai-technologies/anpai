#include <Rcpp.h>
#include <fstream>
#include <sstream>
#include <string>
#include <algorithm>
#include <cctype>
#include <regex>

using namespace Rcpp;

//[[Rcpp::export]]
DataFrame read_ics_rcpp(std::string path) {
  
  // read whole file as string to estimate # of events
  std::ifstream inFile(path);
  inFile.open(path); 
  std::stringstream strStream;
  strStream << inFile.rdbuf(); 
  
  // whole_file holds the content of the file
  std::string whole_file = strStream.str(); 
  
  // define event identifier
  std::string target = "BEGIN:VEVENT";
  std::string::size_type start = 0;
  int occurrences = 0;
  
  // count number of events
  while ((start = whole_file.find(target, start)) != std::string::npos) {
    ++occurrences;
    start += target.length(); 
  }
  
  // open connection to ICS for actual extraction run
  std::ifstream infile(path);
  
  // define vectors to be filled with event details
  CharacterVector att_vec (occurrences*400);
  CharacterVector desc_vec (occurrences*700);
  CharacterVector loc_vec (occurrences);
  CharacterVector tit_vec (occurrences);
  DatetimeVector dts_vec (occurrences);
  DatetimeVector dte_vec (occurrences);
  CharacterVector uid_vec (occurrences);
  DatetimeVector lam_vec (occurrences);
  CharacterVector seq_vec (occurrences);
  CharacterVector org_vec (occurrences);
  CharacterVector tz_vec (occurrences);
  
  // define keywords
  std::string begin_key ("BEGIN:VEVENT");
  std::string finish_key ("END:VEVENT");
  std::string attendee_key ("ATTENDEE");
  std::string attendee_key_2 ("NUM-GUESTS");
  std::string tz_key ("TIMEZONE:");
  std::string desc_key ("DESCRIPTION:");
  std::string location_key ("LOCATION:");
  std::string summary_key ("SUMMARY");
  std::string start_key ("DTSTART");
  std::string end_key ("DTEND");
  std::string organizer_key ("ORGANIZER");
  std::string uid_key ("UID:");
  std::string last_modified_key ("LAST-MODIFIED");
  std::string seq_key ("SEQUENCE");
  // this string will be used for mullti-line fields
  std::string sep_string ("|||");
  // will be used for each line
  std::string line;
  // to be assigned the timezone
  std::string tz_id;
  
  // initialize bools
  bool prev_was_attendee = false;
  bool prev_was_desc = false;
  bool desc_bool = false;
  bool tz_bool = false;
  bool att_bool = false;
  bool loc_bool = false;
  bool sum_bool = false;
  bool start_bool = false;
  bool end_bool = false;
  bool org_bool = false;
  bool uid_bool = false;
  bool lm_bool = false;
  bool seq_bool = false;
  bool first = true;
  
  // define counters
  // -> i counts for events and should equal the number of events
  // -> u is the counter for the line of the file currently processed
  int i = 0;
  int u = 0;
  
  // loop over each line
  // logic: until each component of an event has been identified, no new event recording is allowed
  // -> all bools have to be set to true for a new event to begin
  // -> most properties or one line only except for attendees and the description of an event
  while (std::getline(infile, line) && (i <= occurrences))
  {
    
    // start an event -> reset bools
    if (line.find(begin_key) != std::string::npos) {
      att_bool = false;
      desc_bool = false;
      loc_bool = false;
      sum_bool = false;
      start_bool = false;
      end_bool = false;
      org_bool = false;
      uid_bool = false;
      lm_bool = false;
      seq_bool = false;
      tz_bool = false;
      
      if (first == true) {
        first = false;
      } else {
        i += 1;
      }
    } 
    
    // extract attendees
    if ((line.find(attendee_key) != std::string::npos) || (line.find(attendee_key_2) != std::string::npos) || (line.find("STS=0") != std::string::npos)) {
      // next line is assumed to be an attendee line too
      prev_was_attendee = true;
      att_bool = true;
      att_vec[u] = std::regex_replace(line,std::regex("\\r| "), "");
    } 
    
    // attendee lines end -> add separating string & end attendee assumption
    if ((prev_was_attendee) && (line.find("CREATED") != std::string::npos)) {
      prev_was_attendee = false;
      att_bool = true;
      att_vec[u] = sep_string;
    }
    
    // extract description -> same workflow as for attendees
    if (line.find(desc_key) != std::string::npos) {
      prev_was_desc = true;
      desc_bool = true;
      desc_vec[u] = std::regex_replace(line, std::regex("DESCRIPTION:|\\r"), "");
    } 
    
    if ((prev_was_desc) && (line.find("LAST-MODIFIED:") != std::string::npos)) {
      prev_was_desc = false;
      desc_bool = true;
      desc_vec[u] = sep_string;
    }
    
    // extract location
    if ((line.find(location_key) != std::string::npos) && (line.find("-LOCATION") == std::string::npos)  && (line.find("LOCATION") == std::string::npos)) {
      loc_vec[i] = std::regex_replace(line, std::regex("LOCATION:|\\r"), "");
      loc_bool = true;
    } 
    
    // extract event title
    if (line.find(summary_key) != std::string::npos) {
      tit_vec[i] = std::regex_replace(line, std::regex("SUMMARY:|\\r"), "");
      sum_bool = true;
    } 
    
    // get event start time & convert to datetime
    if ((line.find(start_key) != std::string::npos) && (line.find("1970") == std::string::npos)) {
      dts_vec[i] = Datetime(std::regex_replace(line, std::regex("DTSTART.*:|\\r"), ""), "%Y%m%dT%H%M%SZ");
      start_bool = true;
    } 
    
    // get event end time & convert to datetime
    if ((line.find(end_key) != std::string::npos) && (line.find("1970") == std::string::npos)) {
      dte_vec[i] = Datetime(std::regex_replace(line, std::regex("DTEND.*:|\\r"), ""), "%Y%m%dT%H%M%SZ");
      end_bool = true;
    } 
    
    // get event id
    if (line.find(uid_key) != std::string::npos) {
      uid_vec[i] = std::regex_replace(line, std::regex("UID:|\\r"), "");
      uid_bool = true;
    } 
    
    // get the timezone
    if ((line.find(tz_key) != std::string::npos)) {
      tz_id = std::regex_replace(line, std::regex(".*TIMEZONE:|\\r"), "");
    } 
    
    if (line.find(last_modified_key) != std::string::npos) {
      if (tz_id == "") {
        tz_vec[i] = "";
      } else {
        tz_vec[i] = tz_id;
      }
      tz_bool = true;
    } 
    
    // get last modified time & convert to datetime
    if (line.find(last_modified_key) != std::string::npos) {
      lam_vec[i] = Datetime(std::regex_replace(line, std::regex("LAST-MODIFIED:|\\r"), ""), "%Y%m%dT%H%M%SZ");
      lm_bool = true;
    }
    
    // get number of modifications
    if ((line.find(seq_key) != std::string::npos) && (line.find("-"+seq_key) == std::string::npos)) {
      seq_vec[i] = std::regex_replace(line, std::regex("SEQUENCE:|\\r"), "");
      seq_bool = true;
    }
    
    // extract organizer
    if (line.find(organizer_key) != std::string::npos) {
      org_vec[i] = std::regex_replace(line, std::regex("ORGANIZER.*mailto:|\\r"), "");
      org_bool = true;
    }
    
    // end the event if all components have been identified
    // if there are missing values, insert appropriate fillers
    if (line.find(finish_key) != std::string::npos) {
      
      if (att_bool == false) {
        att_vec[u] =  " |||";
      }
      
      if (desc_bool == false) {
        desc_vec[u] =  " |||";
      }
      
      if (tz_bool == false) {
        tz_vec[u] =  "";
      }
      
      if (loc_bool == false) {
        loc_vec[i] = "";
      }
      
      if (sum_bool == false) {
        tit_vec[i] = "";
      }
      
      if (start_bool == false) {
        dts_vec[i] = R_NaN;
      }
      
      if (end_bool == false) {
        dte_vec[i] = R_NaN;
      }
      
      if (org_bool == false) {
        org_vec[i] = "";
      }
      
      if (uid_bool == false) {
        uid_vec[i] = "";
      }
      
      if (lm_bool == false) {
        lam_vec[i] = R_NaN;
      }
      
      if (seq_bool == false) {
        seq_vec[i] = "";
      }
    } 
    
    // increase counter
    u += 1;
  }
  
  // for the multiline fields, the lines belonging to the same event need to be concatenated
  CharacterVector temp;
  std::string curr_atts;
  for (auto & element : att_vec) {
    std::string el = String(element).get_cstring();
    if (el.find(sep_string) != std::string::npos) {
      temp.push_back(curr_atts);
      curr_atts = "";
    } else {
      curr_atts += el;
    }
  }
  
  CharacterVector temp2;
  std::string curr_descs;
  for (auto & element : desc_vec) {
    //element.doSomething ();
    std::string el = String(element).get_cstring();
    if (el.find(sep_string) != std::string::npos) {
      temp2.push_back(curr_descs);
      curr_descs = "";
    } else {
      curr_descs += el;
    }
  }
  
  // return a new data frame
  return DataFrame::create(_["meetingAttendees"]= temp,
                           _["meetingLocation"]= loc_vec,
                           _["meetingTitle"]= tit_vec,
                           _["meetingDescription"]= temp2,
                           _["meetingStart"]= dts_vec,
                           _["meetingEnd"]= dte_vec,
                           _["meetingId"]= uid_vec,
                           _["meetingLastModified"]= lam_vec,
                           _["meetingRevisions"]= seq_vec,
                           _["meetingOrganizer"]= org_vec,
                           _["timeZone"] = tz_vec,
                           _["stringsAsFactors"] = false);
} 