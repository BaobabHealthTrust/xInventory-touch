class HomeController < ApplicationController
  def index
    (session || {}).each do |name , values|
      next if name == 'user_id'
      next if name == 'flash'
      next if name == '_csrf_token'
      session[name] = nil
    end 

    @page_title=<<EOF
<form id="barcodeForm" action="/find_by_barcode">
<input id="barcode" class="touchscreenTextInput" type="text" value="" name="barcode">
<input type="submit" value="Submit" style="display:none" name="commit">
</form>
EOF

    render :layout => 'index'
  end

end
