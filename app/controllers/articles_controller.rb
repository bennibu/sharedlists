# encoding: utf-8

class ArticlesController < ApplicationController

  before_filter :authenticate_supplier_admin!
               
  # GET /supplier/:id/articles
  # GET /supplier/:id/articles.xml
  def index
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
    @article = @supplier.articles.find(params[:id])

    respond_to do |format|
      format.html # show.haml
      format.xml  { render :xml => @article.to_xml }
    end
  end

  # GET /supplier/1/articles/new
  def new
    @article = @supplier.articles.build
  end

  # GET /supplier/1/articles/1/edit
  def edit
    @article = @supplier.articles.find(params[:id])
  end

  # POST /supplier/1/articles
  # POST /supplier/1/articles.xml
  def create
    @article = Article.new(params[:article])
    respond_to do |format|
      if @article.save
        flash[:notice] = 'Article was successfully created.'
        format.html { redirect_to supplier_article_url(@article.supplier, @article) }
        format.xml  { head :created, :location => supplier_article_url(@article.supplier, @article) }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @article.errors.to_xml }
      end
    end
  end

  # PUT /supplier/1/articles/1
  # PUT /supplier/1/articles/1.xml
  def update
    @article = @supplier.articles.find(params[:id])
    respond_to do |format|
      if @article.update_attributes(params[:article])
        flash[:notice] = 'Article was successfully updated.'
        format.html { redirect_to supplier_article_url(@article.supplier, @article) }
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
    @article = @supplier.articles.find(params[:id])
    @article.destroy

    respond_to do |format|
      format.html { redirect_to supplier_articles_url(@supplier) }
      format.xml  { head :ok }
    end
  end
  
  # Renders the upload form
  def upload
  end

  # parse the file to load articles  
  # checks if the article should be updated, create or destroyed
  def parse
    Article.transaction do
      Article.delete_all :supplier_id => @supplier.id unless params[:delete_existing].blank?

      @outlisted_counter, @new_counter, @updated_counter, @invalid_articles =
          @supplier.update_articles_from_file(params[:articles]["file"].read, params[:type], params[:character_set])

      if @invalid_articles.empty?
        flash[:notice] = "Hochladen erfolgreich: #{@new_counter} neue, #{@updated_counter} aktualisiert und #{@outlisted_counter} ausgelistet."
        redirect_to supplier_articles_url(@supplier)
      else
        flash[:error] = "#{@invalid_articles.size} Artikel konnte(n) nicht gespeichert werden"
        render :template => 'articles/parse_errors'
      end
    end
  rescue => error
    flash[:error] = "Fehler beim hochladen der Artikel: #{error.message}"
    redirect_to upload_supplier_articles_url(@supplier)
  end
  
  
  # deletes all articles of a supplier
  def destroy_all
    Article.delete_all :supplier_id => @supplier.id
    flash[:notice] = "Alle Artikel wurden gelöscht"
    redirect_to supplier_articles_url(@supplier)
  end
  
end
