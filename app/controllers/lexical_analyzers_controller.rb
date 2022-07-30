class LexicalAnalyzersController < ApplicationController

  def index
    @lexical_analyzer=LexicalAnalyzer.find(1)
    @worddiv = @lexical_analyzer.progtext.split(' ')
    @idx_ident=0
    @idx_math=0
    @n_line=1
  end

  def update
    @lexical_analyzer = LexicalAnalyzer.find(1)
    if @lexical_analyzer.update(text_params)
      redirect_to root_path
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private
  def text_params
    params.require(:lexical_analyzer).permit(:progtext)
  end
end
