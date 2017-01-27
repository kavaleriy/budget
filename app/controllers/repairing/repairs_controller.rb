module Repairing
  class RepairsController < ApplicationController
    layout 'application_admin'
    # before_action :check_admin_permission, except: [:cross_busroute_with_repairings]
    layout 'application' , only: [:cross_busroute_with_repairings]
    before_filter :update_repairing_coordinates, only: [:update]

    before_action :set_repairing_repair, only: [:show, :edit, :update, :destroy, :show_repair_info]

    # GET  /repairing/repairs
    # GET /repairing/repairs.json
    def index
      @repairing_repairs = Repairing::Repair.all
    end

    # GET /repairing/repairs/1
    # GET /repairing/repairs/1.json
    def show
      respond_to do |format|
        format.json { render json: Repairing::GeojsonBuilder.build_repair(@repairing_repair) }
      end
    end

    # GET /repairing/repairs/new
    def new
      @repairing_repair = Repairing::Repair.new
    end

    # GET /repairing/repairs/1/edit
    def edit

      respond_to do |format|
        format.js { render :edit }
      end
    end

    # POST /repairing/repairs
    # POST /repairing/repairs.json
    def create
      layer = Repairing::Layer.find(params[:layer_id])

      @repairing_repair = layer.repairs.new(repairing_repair_params)

      respond_to do |format|
        if @repairing_repair.save
          format.json { render :show, status: :created, location: @repairing_map_repair }
        else
          format.html { render :new }
          format.json { render json: @repairing_repair.errors, status: :unprocessable_entity }
        end
      end
    end

    # PATCH/PUT /repairing/repairs/1
    # PATCH/PUT /repairing/repairs/1.json
    def update
      respond_to do |format|
        if @repairing_repair.update(repairing_repair_params)
          flash[:notice] = I18n.t('repairing.layers.update.success')
          format.js {}
          format.json { render :show, status: :ok }
        else
          format.json { render json: @repairing_repair.errors, status: :unprocessable_entity }
        end
      end
    end

    # DELETE /repairing/repairs/1
    # DELETE /repairing/repairs/1.json
    def destroy
      @repairing_repair.destroy
      respond_to do |format|
        format.js
      end
    end

    def show_repair_info
    end

    def cross_busroute_with_repairings
      @routes = [["48.39046", "35.03731"], ["48.39064", "35.03706"], ["48.39064", "35.03706"], ["48.3901", "35.03621"], ["48.39001", "35.03607"], ["48.39001", "35.03607"], ["48.39012", "35.03563"], ["48.39037", "35.03461"], ["48.39055", "35.03389"], ["48.3906", "35.03371"], ["48.39069", "35.03332"], ["48.39079", "35.0329"], ["48.39095", "35.03232"], ["48.39101", "35.03213"], ["48.39107", "35.03199"], ["48.39112", "35.03189"], ["48.39119", "35.03181"], ["48.39133", "35.03167"], ["48.39169", "35.03133"], ["48.39187", "35.03117"], ["48.39268", "35.03041"], ["48.39286", "35.03024"], ["48.39359", "35.02956"], ["48.39366", "35.0295"], ["48.39405", "35.02914"], ["48.39503", "35.02821"], ["48.39563", "35.02762"], ["48.39622", "35.02709"], ["48.39661", "35.02677"], ["48.39705", "35.02647"], ["48.39773", "35.02606"], ["48.39808", "35.02587"], ["48.39833", "35.02582"], ["48.39842", "35.02581"], ["48.39882", "35.02596"], ["48.39913", "35.0261"], ["48.39913", "35.0261"], ["48.39917", "35.02614"], ["48.39949", "35.02648"], ["48.39958", "35.02659"], ["48.39965", "35.02669"], ["48.39974", "35.02684"], ["48.39984", "35.02703"], ["48.39984", "35.02703"], ["48.39999", "35.02746"], ["48.40035", "35.02846"], ["48.4005", "35.02886"], ["48.40073", "35.02951"], ["48.40098", "35.03021"], ["48.40112", "35.0306"], ["48.40121", "35.03086"], ["48.40149", "35.03164"], ["48.40184", "35.03259"], ["48.4022", "35.0336"], ["48.4025", "35.03443"], ["48.40254", "35.03454"], ["48.4027", "35.035"], ["48.40276", "35.0352"], ["48.4028", "35.0353"], ["48.40283", "35.0354"], ["48.40283", "35.0354"], ["48.40422", "35.03427"], ["48.40481", "35.0338"], ["48.40522", "35.03347"], ["48.40619", "35.03269"], ["48.40726", "35.03183"], ["48.40802", "35.03121"], ["48.40881", "35.03058"], ["48.40942", "35.03008"], ["48.40959", "35.02994"], ["48.40994", "35.02965"], ["48.4101", "35.02953"], ["48.41039", "35.02929"], ["48.41234", "35.02773"], ["48.41411", "35.0263"], ["48.41463", "35.02589"], ["48.41475", "35.02578"], ["48.41534", "35.0253"], ["48.41705", "35.02393"], ["48.41736", "35.02371"], ["48.41759", "35.02356"], ["48.4178", "35.02344"], ["48.41806", "35.02332"], ["48.41877", "35.02305"], ["48.41923", "35.02289"], ["48.41947", "35.02282"], ["48.41976", "35.02278"], ["48.41998", "35.02279"], ["48.42013", "35.02281"], ["48.42033", "35.02286"], ["48.42064", "35.02295"], ["48.42126", "35.02314"], ["48.42203", "35.0234"], ["48.42246", "35.02355"], ["48.42257", "35.02358"], ["48.42275", "35.02365"], ["48.42338", "35.02387"], ["48.42408", "35.02412"], ["48.42423", "35.02418"], ["48.4244", "35.02426"], ["48.42459", "35.02436"], ["48.42459", "35.02436"], ["48.42466", "35.02441"], ["48.42473", "35.02444"], ["48.42478", "35.02443"], ["48.42483", "35.02441"], ["48.42489", "35.02436"], ["48.42494", "35.02429"], ["48.42497", "35.02423"], ["48.42499", "35.02417"], ["48.42505", "35.024"], ["48.42511", "35.0239"], ["48.42518", "35.02379"], ["48.42529", "35.02364"], ["48.42542", "35.02351"], ["48.42544", "35.02349"], ["48.42549", "35.02344"], ["48.4256", "35.02333"], ["48.4256", "35.02333"], ["48.42664", "35.02231"], ["48.42727", "35.02172"], ["48.42787", "35.02111"], ["48.42796", "35.02103"], ["48.42809", "35.02089"], ["48.42823", "35.02076"], ["48.42851", "35.02051"], ["48.4288", "35.02028"], ["48.42915", "35.02001"], ["48.42949", "35.01976"], ["48.43023", "35.01924"], ["48.43078", "35.01885"], ["48.43108", "35.01863"], ["48.4321", "35.01789"], ["48.43226", "35.01778"], ["48.43338", "35.01699"], ["48.43338", "35.01699"], ["48.43413", "35.01742"], ["48.43496", "35.0179"], ["48.43591", "35.01846"], ["48.43625", "35.01867"], ["48.43664", "35.01895"], ["48.43719", "35.01934"], ["48.43725", "35.01938"], ["48.43733", "35.01944"], ["48.43793", "35.01996"], ["48.43855", "35.02052"], ["48.43922", "35.02115"], ["48.43962", "35.02151"], ["48.44036", "35.02221"], ["48.44042", "35.02227"], ["48.44042", "35.02227"], ["48.4405", "35.02207"], ["48.44054", "35.02198"], ["48.44073", "35.02151"], ["48.44086", "35.02118"], ["48.44099", "35.02086"], ["48.44137", "35.0199"], ["48.44162", "35.01917"], ["48.44168", "35.01897"], ["48.44192", "35.01802"], ["48.44214", "35.01714"], ["48.44217", "35.01703"], ["48.44217", "35.01703"], ["48.44227", "35.01708"], ["48.44349", "35.0177"], ["48.44378", "35.01786"], ["48.44389", "35.01792"], ["48.44532", "35.01866"], ["48.44641", "35.01925"], ["48.44912", "35.02067"], ["48.44957", "35.02092"], ["48.44976", "35.02102"], ["48.44987", "35.02108"], ["48.45006", "35.02118"], ["48.45015", "35.02123"], ["48.45109", "35.02172"], ["48.45154", "35.02196"], ["48.45221", "35.02231"], ["48.45232", "35.02237"], ["48.45438", "35.02345"], ["48.45447", "35.0235"], ["48.45503", "35.02379"], ["48.45509", "35.02382"], ["48.45512", "35.02383"], ["48.45517", "35.02386"], ["48.45522", "35.02389"], ["48.4564", "35.02453"], ["48.45647", "35.02457"], ["48.45735", "35.02504"], ["48.45753", "35.02514"], ["48.45854", "35.02568"], ["48.45926", "35.02607"], ["48.45935", "35.02611"], ["48.46065", "35.0268"], ["48.46078", "35.02688"], ["48.46088", "35.02693"], ["48.46114", "35.02706"], ["48.46166", "35.02733"], ["48.46215", "35.0276"], ["48.4626", "35.02784"], ["48.4629", "35.02799"], ["48.463", "35.02804"], ["48.46314", "35.02812"], ["48.46355", "35.02834"], ["48.46392", "35.02854"], ["48.46465", "35.02893"], ["48.46496", "35.02911"], ["48.46504", "35.02915"], ["48.46512", "35.02919"], ["48.46523", "35.02925"], ["48.46533", "35.0293"], ["48.46533", "35.0293"], ["48.46541", "35.02895"], ["48.46544", "35.02884"], ["48.46619", "35.02574"], ["48.46647", "35.02459"], ["48.46656", "35.02422"], ["48.46686", "35.02295"], ["48.46698", "35.02246"], ["48.46725", "35.02131"], ["48.46726", "35.02127"], ["48.46726", "35.02126"], ["48.46727", "35.02122"], ["48.46753", "35.0201"], ["48.46786", "35.01862"], ["48.4679", "35.01846"], ["48.46793", "35.01831"], ["48.46818", "35.01731"], ["48.46824", "35.01704"], ["48.46849", "35.0159"], ["48.46854", "35.0157"], ["48.46858", "35.01551"], ["48.46868", "35.01507"], ["48.46887", "35.01426"], ["48.46899", "35.0137"], ["48.469", "35.01367"], ["48.46903", "35.01357"], ["48.46904", "35.01353"], ["48.46927", "35.01253"], ["48.46934", "35.01223"], ["48.46937", "35.01209"], ["48.46941", "35.01192"], ["48.46959", "35.01112"], ["48.46987", "35.00986"], ["48.47002", "35.00921"], ["48.4701", "35.00893"], ["48.47013", "35.0089"], ["48.47016", "35.00884"], ["48.47032", "35.00864"], ["48.47086", "35.00792"], ["48.47123", "35.00746"], ["48.47141", "35.00724"], ["48.47146", "35.00717"], ["48.47154", "35.00707"], ["48.47159", "35.007"], ["48.47165", "35.0069"], ["48.4717", "35.0068"], ["48.47227", "35.00509"], ["48.47266", "35.0039"], ["48.47275", "35.00365"], ["48.47419", "34.99915"], ["48.47438", "34.99857"], ["48.47524", "34.99587"], ["48.47529", "34.99572"], ["48.47537", "34.9956"], ["48.47544", "34.99544"], ["48.47664", "34.99168"], ["48.47679", "34.99119"], ["48.47684", "34.99097"], ["48.47686", "34.99079"], ["48.47688", "34.99064"], ["48.47689", "34.99039"], ["48.4769", "34.99004"], ["48.47685", "34.98843"], ["48.47685", "34.98815"], ["48.47684", "34.98799"], ["48.4768", "34.98764"], ["48.47678", "34.9875"], ["48.47675", "34.9858"], ["48.47675", "34.98521"], ["48.47673", "34.98424"], ["48.47671", "34.98293"], ["48.4767", "34.98183"], ["48.47668", "34.98072"], ["48.47667", "34.98044"], ["48.47666", "34.98029"], ["48.47663", "34.97893"], ["48.47661", "34.97798"], ["48.47656", "34.9756"], ["48.47653", "34.97452"], ["48.47653", "34.97425"], ["48.47653", "34.97412"], ["48.47653", "34.97374"], ["48.47631", "34.96896"], ["48.47631", "34.96896"], ["48.47628", "34.96709"], ["48.47625", "34.96493"], ["48.47621", "34.96367"], ["48.47611", "34.96208"], ["48.47596", "34.96048"], ["48.4758", "34.95922"], ["48.47563", "34.95792"], ["48.47554", "34.95717"], ["48.4752", "34.95534"], ["48.47518", "34.95511"], ["48.47505", "34.9541"], ["48.47501", "34.95382"], ["48.47486", "34.95306"], ["48.47433", "34.95058"], ["48.47433", "34.95058"], ["48.47438", "34.95054"], ["48.47467", "34.95034"], ["48.47467", "34.95034"], ["48.47486", "34.95005"], ["48.47496", "34.94989"], ["48.47503", "34.94969"], ["48.47509", "34.94947"], ["48.47512", "34.94922"], ["48.47512", "34.94863"], ["48.47518", "34.9484"], ["48.47529", "34.94828"], ["48.47529", "34.94828"], ["48.47551", "34.94834"], ["48.47563", "34.94837"], ["48.47645", "34.94869"], ["48.47698", "34.94886"], ["48.47749", "34.94893"], ["48.47772", "34.94896"], ["48.47812", "34.949"], ["48.47851", "34.94906"], ["48.47858", "34.94907"], ["48.47869", "34.94909"], ["48.47921", "34.94923"], ["48.47969", "34.94941"], ["48.48017", "34.94956"], ["48.48056", "34.9497"], ["48.48076", "34.9497"], ["48.4808", "34.94968"], ["48.48084", "34.94966"], ["48.48084", "34.94966"], ["48.48046", "34.94647"], ["48.48038", "34.94578"], ["48.4803", "34.94492"], ["48.48028", "34.94469"], ["48.48026", "34.94452"], ["48.48023", "34.94422"], ["48.48022", "34.94411"], ["48.4802", "34.94392"], ["48.4802", "34.94387"], ["48.48018", "34.94372"], ["48.48012", "34.94294"], ["48.48003", "34.94253"], ["48.48003", "34.94244"], ["48.48", "34.94163"], ["48.48001", "34.94078"], ["48.48", "34.94024"], ["48.48001", "34.93956"], ["48.48", "34.93785"], ["48.47997", "34.9369"], ["48.47996", "34.93644"], ["48.47991", "34.93511"], ["48.47988", "34.93439"], ["48.47988", "34.93334"], ["48.47988", "34.93307"], ["48.47988", "34.93295"], ["48.47983", "34.93164"], ["48.47978", "34.93094"], ["48.47973", "34.93036"], ["48.47972", "34.93014"], ["48.47969", "34.9297"], ["48.47967", "34.92928"], ["48.47966", "34.92907"], ["48.47966", "34.92907"], ["48.47963", "34.92841"], ["48.47963", "34.92833"], ["48.47967", "34.92817"], ["48.47968", "34.92815"], ["48.47971", "34.92809"], ["48.47978", "34.92801"], ["48.47985", "34.92796"], ["48.47991", "34.92791"], ["48.47997", "34.92786"], ["48.48041", "34.92744"], ["48.48068", "34.9272"], ["48.48118", "34.92676"], ["48.48141", "34.92656"], ["48.4819", "34.92613"], ["48.4822", "34.92588"], ["48.4825", "34.9256"], ["48.48262", "34.92549"], ["48.4829", "34.92525"], ["48.48314", "34.92504"], ["48.48369", "34.92459"], ["48.48401", "34.92435"], ["48.48456", "34.92388"], ["48.48493", "34.92362"], ["48.48521", "34.92347"], ["48.48533", "34.92341"], ["48.48544", "34.92336"], ["48.48566", "34.92323"], ["48.48569", "34.92321"], ["48.48576", "34.92317"], ["48.48585", "34.92301"], ["48.48585", "34.92301"], ["48.48566", "34.92184"], ["48.4855", "34.92074"], ["48.48507", "34.91787"], ["48.48489", "34.91676"], ["48.48474", "34.9157"], ["48.48455", "34.91445"], ["48.48439", "34.91334"], ["48.48434", "34.91301"], ["48.48414", "34.91164"], ["48.48412", "34.91144"], ["48.48411", "34.91126"], ["48.4839", "34.90814"], ["48.48388", "34.908"], ["48.48383", "34.90788"], ["48.48376", "34.90776"], ["48.48376", "34.90776"], ["48.48371", "34.90769"], ["48.48367", "34.90765"], ["48.48362", "34.9076"], ["48.48355", "34.90755"], ["48.48348", "34.90753"], ["48.48329", "34.90748"], ["48.48313", "34.90745"], ["48.48295", "34.90746"], ["48.48263", "34.9075"], ["48.482", "34.90759"], ["48.48149", "34.90765"], ["48.48144", "34.90766"], ["48.48096", "34.90769"], ["48.48065", "34.90769"], ["48.48049", "34.90768"], ["48.48046", "34.90768"], ["48.4804", "34.90751"], ["48.48031", "34.90716"], ["48.48021", "34.90674"], ["48.48009", "34.90624"], ["48.48009", "34.90624"], ["48.48032", "34.90607"], ["48.48055", "34.90592"], ["48.48055", "34.90592"], ["48.48058", "34.90605"], ["48.4808", "34.90703"], ["48.4808", "34.90703"]]
      @routes.each_with_index do |route, index|
        # binding.pry
        @routes[index][0] = route[0].to_f
        @routes[index][1] = route[1].to_f
        # @routes.first[index] = @routes.first[index].to_f
      end
      @routes = (0..@routes.size - 2).map{ |i|
        [@routes[i], @routes[i+1]]
      }
      # layers = Repairing::Layer.where(town_id: Town.where(title: 'Дніпропетровськ').first)
      # repair = Repairing::Repair.find_by(edrpou_artist: '11111111')
      # binding.pry
      @repairings = [["48.47454", "35.00074"], ["48.47431", "35.00181"], ["48.47418", "35.00246"], ["48.47411", "35.00286"], ["48.47389", "35.00409"], ["48.47389", "35.00409"], ["48.47373", "35.00405"], ["48.47349", "35.00396"], ["48.47305", "35.00378"], ["48.47275", "35.00365"], ["48.47275", "35.00365"], ["48.47266", "35.0039"], ["48.47227", "35.00509"], ["48.4717", "35.0068"], ["48.47165", "35.0069"], ["48.47159", "35.007"], ["48.47154", "35.00707"], ["48.47146", "35.00717"], ["48.47141", "35.00724"], ["48.47123", "35.00746"], ["48.47086", "35.00792"], ["48.47032", "35.00864"], ["48.47016", "35.00884"], ["48.47013", "35.0089"], ["48.4701", "35.00893"], ["48.4701", "35.00893"], ["48.46988", "35.00916"], ["48.46969", "35.00943"], ["48.46961", "35.00972"], ["48.46958", "35.00983"], ["48.4695", "35.01015"], ["48.46931", "35.01092"], ["48.46931", "35.01092"], ["48.46915", "35.01167"], ["48.46909", "35.01195"], ["48.46906", "35.01207"], ["48.46905", "35.01212"], ["48.46874", "35.01341"], ["48.46871", "35.01352"], ["48.46827", "35.01535"], ["48.46823", "35.01555"], ["48.46818", "35.01574"], ["48.46791", "35.01686"], ["48.46761", "35.01814"], ["48.46758", "35.01828"], ["48.46754", "35.01846"], ["48.46737", "35.01922"], ["48.46693", "35.02109"], ["48.4668", "35.02163"], ["48.46655", "35.02275"], ["48.46644", "35.02319"], ["48.46637", "35.02351"], ["48.46633", "35.02367"], ["48.46633", "35.02367"], ["48.46633", "35.02367"], ["48.46624", "35.02404"], ["48.46622", "35.02415"], ["48.4662", "35.02423"], ["48.46618", "35.02433"], ["48.46616", "35.02444"], ["48.46586", "35.02568"], ["48.46575", "35.02615"], ["48.4656", "35.02678"], ["48.46538", "35.02769"], ["48.46515", "35.02867"], ["48.46512", "35.02879"], ["48.46504", "35.02915"], ["48.46501", "35.02928"], ["48.46469", "35.03073"], ["48.46442", "35.03188"], ["48.46433", "35.03228"], ["48.4643", "35.0324"], ["48.46427", "35.03249"], ["48.46422", "35.03261"], ["48.46414", "35.03275"], ["48.46366", "35.03364"], ["48.46307", "35.03473"], ["48.46279", "35.03523"], ["48.46277", "35.03528"], ["48.46229", "35.03616"], ["48.46223", "35.03626"], ["48.46216", "35.03638"], ["48.4612", "35.03812"], ["48.46086", "35.03871"], ["48.46082", "35.03878"], ["48.46078", "35.03885"], ["48.46069", "35.03902"], ["48.45992", "35.04046"], ["48.45904", "35.04208"], ["48.45899", "35.04216"], ["48.45892", "35.04229"], ["48.45812", "35.04374"], ["48.45806", "35.04386"], ["48.45801", "35.04395"], ["48.45779", "35.04437"], ["48.45719", "35.04546"], ["48.45636", "35.04701"], ["48.45621", "35.04728"], ["48.45608", "35.0475"], ["48.45607", "35.04753"], ["48.45585", "35.04789"], ["48.45585", "35.04789"], ["48.4553", "35.04893"], ["48.45502", "35.04945"], ["48.45474", "35.04999"], ["48.45461", "35.05022"], ["48.4545", "35.05039"], ["48.45427", "35.05071"], ["48.45427", "35.05071"], ["48.4542", "35.05071"], ["48.45411", "35.05071"], ["48.45202", "35.05004"], ["48.45189", "35.05002"], ["48.45177", "35.05003"], ["48.4517", "35.05005"], ["48.45163", "35.05011"], ["48.45158", "35.05019"], ["48.45135", "35.05056"], ["48.45122", "35.05078"], ["48.45104", "35.05108"], ["48.45067", "35.05178"], ["48.45048", "35.05248"], ["48.45008", "35.05389"], ["48.45", "35.05414"], ["48.44932", "35.05538"], ["48.44923", "35.05543"], ["48.44923", "35.05543"], ["48.44908", "35.0553"], ["48.4489", "35.05524"], ["48.44861", "35.05513"], ["48.44849", "35.05511"], ["48.44837", "35.05514"], ["48.44825", "35.05528"], ["48.44745", "35.05678"], ["48.44745", "35.05678"], ["48.4466", "35.05568"], ["48.4466", "35.05568"], ["48.44641", "35.05597"], ["48.44632", "35.05613"], ["48.4463", "35.05618"], ["48.44614", "35.05648"], ["48.44595", "35.05683"], ["48.44586", "35.057"], ["48.44573", "35.05724"], ["48.4457", "35.05729"], ["48.44564", "35.05741"], ["48.44544", "35.05778"], ["48.44527", "35.05809"], ["48.44479", "35.05851"], ["48.44461", "35.05859"], ["48.44461", "35.05859"], ["48.44436", "35.05853"], ["48.44243", "35.05805"], ["48.44201", "35.05765"], ["48.44201", "35.05765"], ["48.4411", "35.05687"], ["48.44044", "35.05639"], ["48.43922", "35.05544"], ["48.43847", "35.05483"], ["48.43829", "35.0547"], ["48.43687", "35.05364"], ["48.43593", "35.05286"], ["48.43593", "35.05286"], ["48.4363", "35.05226"], ["48.4363", "35.05226"], ["48.43553", "35.05131"], ["48.43431", "35.04991"], ["48.43394", "35.04946"], ["48.43365", "35.04913"], ["48.43365", "35.04913"], ["48.43358", "35.04844"], ["48.43358", "35.04844"], ["48.43148", "35.04564"], ["48.43109", "35.04563"], ["48.43109", "35.04563"], ["48.43193", "35.04405"], ["48.43193", "35.04405"]]

      # layers.each do |layer|
        # layer.repairs.each do |repair|
        #   if repair.coordinates && repair.coordinates[0].kind_of?(Array)
        #     temp = []
        #     repair.coordinates.each do |coords|
        #       repairings << coords
        #     end
        #
        #   end
        # end
      # end
      @repairings.each_with_index do |repair, index|
        @repairings[index][0] = repair[0].to_f
        @repairings[index][1] = repair[1].to_f
        # routes.first[index] = routes.first[index].to_f
      end
      @repairings = (0..@repairings.size - 2).map{ |i|
        [@repairings[i], @repairings[i+1]]
      }

      @crosses = []
      # lines = (0..arr.count - 2).map{ |i| [arr[i], arr[i+1]] }
      find_cross = ->(line1, line2) do
        # line1 = [[49.2338, 28.46396], [48.39069, 35.03332]]
        # line2 = [[2,1], [2,3.0]]

        if line2[0][0] == line2[1][0]
          line1, line2 = line2, line1
        end

        x1, y1, x2, y2 = line1[0][0], line1[0][1], line1[1][0], line1[1][1]
        x3, y3, x4, y4 = line2[0][0], line2[0][1], line2[1][0], line2[1][1]

        # если паралельные и между ними нету растояния
        return nil if ((y1-y2)*(x4-x3)-(y3-y4)*(x2-x1)) == 0

        # паралельные линии
        return line1 if x4 == x3

        x = -((x1*y2-x2*y1)*(x4-x3)-(x3*y4-x4*y3)*(x2-x1))/((y1-y2)*(x4-x3)-(y3-y4)*(x2-x1))
        y = ((y3-y4)*(-x)-(x3*y4-x4*y3))/(x4-x3)

        return nil unless (((x1<=x) and (x2>=x) and (x3<=x) and (x4>=x)) or ((y1<=y) and (y2>=y) and (y3<=y) and (y4>=y)))

        return line1
      end
      @routes.each do |route|
        @repairings.each do |repair|
          cross = find_cross.call(route, repair)
          unless cross.nil?
            @crosses << cross
          end
        end
      end

      @dtp = [ [48.497381, 35.069956] ,[48.511189, 35.076803], [48.527318, 35.083619], [48.519006, 35.080125], [48.461868, 35.042746], [48.466149, 35.035007] ]
    end
      private
      # Use callbacks to share common setup or constraints between actions.
      def set_repairing_repair
        @repairing_repair = Repairing::Repair.find(params[:id])
      end

      def update_repairing_coordinates
        par = params[:repairing_repair][:coordinates]
        unless (par.nil? || par.kind_of?(Array))
          coordinates = par.split(") ").map{|p| p.split(", ")}.map{|p| [p[0].split("LatLng(")[1],p[1]]}
          params[:repairing_repair][:coordinates] = coordinates
        end
      end

    # Never trust parameters from the scary internet, only allow the white list through.
      def repairing_repair_params
        params.require(:repairing_repair).permit! #(:description, :amount, :repair_date, :address, :address_to, :coordinates).tap { |whitelisted|  whitelisted[:coordinates] = params[:repairing_repair][:coordinates] }
      end
  end
end