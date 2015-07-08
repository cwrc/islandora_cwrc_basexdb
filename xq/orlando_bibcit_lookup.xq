(: 
*
* View cititations within documents  - biography/writing/events 
*
* replace the Orlando Doc Archive Bibcit Lookup Report 
*
* .
*
:)


xquery version "3.0" encoding "utf-8";

import module namespace cwAccessibility="cwAccessibility" at "./islandora_access_control.xq";

declare namespace output = "http://www.w3.org/2010/xslt-xquery-serialization";
declare option output:method "xml";
declare option output:encoding "UTF-8";
declare option output:indent   "no";


declare variable $FEDORA_PID external := "";
declare variable $BASE_URL external := "";



(: the main section: :)
let $accessible_seq := cwAccessibility:queryAccessControl(/)[@pid=$FEDORA_PID]
let $doc_href := fn:concat($BASE_URL,'/',$accessible_seq/@pid/data())
let $doc_label := fn:string-join( ($accessible_seq/@label/data(),  $accessible_seq/@pid/data()), ' - ')

return
  <div>
    <h2 class="xquery_result">
      <a href="{$doc_href}">{$doc_label}</a>
    </h2>
    <div class="xquery_result_list">
    {
      (: find the bibcit reference and combine duplicates :)
      for $group_by_id in distinct-values($accessible_seq//(BIBCIT|TEXTSCOPE)/@DBREF/data())
      order by $group_by_id
      return
        <div>
        <ul>
        {
        (: output details of the reference biblography entry :) 
        let $bibl := cwAccessibility:queryAccessControl(/)[@pid/data()=$group_by_id]
        return
        (
          if ( $bibl/RESPONSIBILITY[@WORKSTATUS="PUB"] and $bibl/RESPONSIBILITY[@WORKVALUE="C"] ) then
            <em class="pub_c">{data($bibl/@BI_ID)}</em>
          else if ( $bibl/RESPONSIBILITY ) then
            <span>{data($bibl/@BI_ID)}</span>
          else
            <d>{$group_by_id} no responsibility found</d>
          )
        }
        </ul>
        <ul>
          {
          (: output placeholder and tag text of ibbcit or textscope :)
          for $a in $accessible_seq//BIBCIT[@DBREF = $group_by_id]
          order by $a/@PLACEHOLDER/data()
          return
            <li>DBREF:[{$a/@DBREF/data()}] - QTDIN:[{$a/@QTDIN/data()}] - Placeholder:[{$a/@PLACEHOLDER/data()}] - Text:[{$a/text()}]</li>
          }
        </ul>
        </div>
    }
    </div>
  </div>

