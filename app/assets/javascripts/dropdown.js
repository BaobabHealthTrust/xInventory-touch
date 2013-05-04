
$(function(){if($.browser.msie&&parseInt($.browser.version,10)===6){$('.row div[class^="span"]:last-child').addClass("last-child");$('[class*    ="span"]').addClass("margin-left-20");$('[class*="span"][class*="offset"]').removeClass('margin-left-20');$(':button[class="btn"], :                   reset[class="btn"], :submit[class="btn"], input[type="button"]').addClass("button-reset");$(":checkbox").addClass("input-checkbox");$('[class^="icon-  "], [class*=" icon-"]').addClass("icon-sprite");$(".pagination li:first-child a").addClass("pagination-first-child")}
                                                                                
        // Tooltip demo                                                         
        $('.tooltip-demo.well').tooltip({                                       
          selector: "a[rel=tooltip]",                                           
          placement: "top"                                                      
        })                                                                      
                                                                                
        $('.tooltip-test').tooltip()                                            
        $('.popover-test').popover()                                            
                                                                                
        // Popover demo                                                         
        $("a[rel=popover]")                                                     
          .popover({                                                            
          placement : "top"                                                     
           })                                                                   
          .click(function(e) {                                                  
          e.preventDefault()                                                    
          })                                                                    
      });

