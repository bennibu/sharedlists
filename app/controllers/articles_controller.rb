require 'faster_csv'

class ArticlesController < ApplicationController
               
  # GET /supplier/:id/articles
  # GET /supplier/:id/articles.xml
  def index
    @supplier = Supplier.find(params[:supplier_id])
    
    if params[:filter]
      @filter = params[:filter]
      @articles = @supplier.articles.paginate :conditions => ['name LIKE ?', "%#{@filter}%"], :page => params[:page]
    elsif params[:order]
      case params[:order]
      when 'updated_on'
        @articles = @supplier.articles.paginate :all, :order => "updated_on DESC", :page => params[:page]
        @updated_on = true
      end
    else
      @articles = @supplier.articles.paginate :page => params[:page]
    end
    
    respond_to do |format|
      format.html # index.haml
      format.xml  { render :xml => @articles.to_xml }
    end
  end

  # GET /supplier/1/articles/1
  # GET /supplier/1/articles/1.xml
  def show
    @article = Article.find(params[:id])

    respond_to do |format|
      format.html # show.haml
      format.xml  { render :xml => @article.to_xml }
    end
  end

  # GET /supplier/1/articles/new
  def new
    @article = Supplier.find(params[:supplier_id]).articles.build
  end

  # GET /supplier/1/articles/1/edit
  def edit
    @article = Article.find(params[:id])
  end

  # POST /supplier/1/articles
  # POST /supplier/1/articles.xml
  def create
    @article = Articles.new(params[:article])
    respond_to do |format|
      if @article.save
        flash[:notice] = 'Article was successfully created.'
        format.html { redirect_to article_url(@article.supplier, @article) }
        format.xml  { head :created, :location => article_url(@article.supplier, @article) }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @article.errors.to_xml }
      end
    end
  end

  # PUT /supplier/1/articles/1
  # PUT /supplier/1/articles/1.xml
  def update
    @article = Article.find(params[:id])
    respond_to do |format|
      if @article.update_attributes(params[:article])
        flash[:notice] = 'Article was successfully updated.'
        format.html { redirect_to article_url(@article.supplier, @article) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @article.errors.to_xml }
      end
    end
  end

  # DELETE /supplier/1/articles/1
  # DELETE /supplier/1/articles/1.xml
  def destroy
    @article = Article.find(params[:id])
    supplier = @article.supplier
    @article.destroy

    respond_to do |format|
      format.html { redirect_to articles_url(supplier) }
      format.xml  { head :ok }
    end
  end
  
  # Renders the upload form
  def upload
    if params[:supplier_id]
      @supplier = Supplier.find(params[:supplier_id])
    else
      flash[:error] = "Kein Lieferant ausgewählt"
      redirect_to suppliers_path
    end
  end

  # parse the file to load articles  
  # checks if the article should be updated, create or destroyed
  def parse
    begin
      @supplier = Supplier.find(params[:supplier])
      @outlisted_counter, @new_counter, @updated_counter, @invalid_articles = 
          @supplier.update_articles_from_file(params[:articles]["file"].read, params[:type], params[:articles]["file"].original_filename, params[:character_set])
          
      if @invalid_articles.empty?
        flash[:notice] = "Hochladen erfolgreich: #{@new_counter} neue, #{@updated_counter} aktualisiert und #{@outlisted_counter} ausgelistet."
        redirect_to articles_url(@supplier)
      else
        flash[:error] = "#{@invalid_articles.size} Artikel konnte(n) nicht gespeichert werden"
        render :template => 'articles/parse_errors'
      end
    rescue => error
      flash[:error] = "Fehler beim hochladen der Artikel: #{error.message}"
      redirect_to upload_articles_url(@supplier)
    end
  end
  
  
  # deletes all articles of a supplier
  def destroy_all
    supplier = Supplier.find(params[:supplier_id])
    Article.delete_all "supplier_id = #{supplier.id}"
    flash[:notice] = "Alle Artikel wurden gelöscht"
    redirect_to articles_url(supplier)
  end
  
end
