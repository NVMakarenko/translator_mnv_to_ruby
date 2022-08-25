module LexicalAnalyzersHelper

  def class_of_char(char)
    abc =['a','b','c','d','e','f','g','h','e','i','j','k','l','m','n','o','p','q','r','s','t','u','v','w','x','y','z']
    dig = ['0','1','2','3','4','5','6','7','8','9']
    math = ['+','-','*','/','^','(',')']
    log = ['>','>=','<','<=','~']
    dot = ['.',':','=',';']

    if dot.find_all{ |elem| elem == char}.size !=0 then 'dot'
    elsif abc.find_all{ |elem| elem == char}.size !=0 then'Letter'
    elsif dig.find_all{ |elem| elem == char}.size !=0 then 'Digit'
    elsif math.find_all{ |elem| elem == char}.size !=0 then 'Math'
    elsif log.find_all{ |elem| elem == char}.size !=0 then 'Log'
    else 'other'
    end
  end

  def get_n_line(char)
    result=get_id(char)
    if result=='new_line'
      @n_line+=1
    else @n_line
    end
  end

  def get_idx_id(char)
    result=get_id(char)
    @idx_ident+=1 if result=='identificator'
  end

  def get_idx_math(char)
    result=get_id(char)
    @idx_math+=1 if result=='real'||result=='integer'
  end

  def get_id(char)
    hook=Array.new
    char.split('').each do |item|
      hook.push(class_of_char(item))
    end
    if (hook.first=='Letter'&& (hook.include?('Math') ||  hook.include?('Log') ||  hook.include?('dot'))) then t('error.102')
    elsif hook.first=='Letter' then get_lexem_type(char)
    elsif (hook.first=='Digit' && hook.include?('dot')&& hook.exclude?('Letter')&& hook.exclude?('Math')&& hook.exclude?('Log')) then 'real'
    elsif (hook.first=='Digit' && hook.exclude?('dot') && hook.exclude?('Letter')&& hook.exclude?('Math') && hook.exclude?('Log')) then 'integer'
    elsif (hook.first=='Digit' && hook.include?('dot')&& hook.include?('Letter')) then t('error.102')
    elsif (hook.first=='dot' && hook.exclude?('Letter')) || hook.include?('Math') || hook.include?('Log') then get_lexem_type(char) #assign, order, etc
    elsif hook.include?('other') then  t('error.103')
    else t('error.104')
    end
  end

  def get_lexem_type(lexem)
    tokenHash = {
      'keyword' => ['program', 'end', 'for', 'to', 'do', 'if', 'goto'],
      'add_op' => ['+','-'],
      'math_op' => ['*','/','^'],
      "log_op" => ['<','<=','>','>=','~', '='],
      'boolean' => ['true','false'],
      'assign' => [':='],
      'order_opp' => ['(', ')'],
      'new_line' => [';']
    }
    find_token = tokenHash.find {|key, values| values.include?(lexem)}
    if find_token != nil
      find_token.first
    elsif lexem.first=='.'
      'real'
    else 'identificator'
    end
  end

  def get_lexan(worddiv)
  hash_token ={}
  array_lexem = []
  worddiv.each do |item|
    hash_token[:num_line]=get_n_line(item)
    hash_token[:lexem_type] = get_id(item)
    hash_token[:lexema] = item
    hash_token[:idx] = get_idx_id(item) if hash_token[:lexem_type]=='identificator'
    hash_token[:idx] = get_idx_math(item) if hash_token[:lexem_type]=='real' || hash_token[:lexem_type]=='integer'
    array_lexem.push(hash_token)
    hash_token=Hash.new
  end
  return array_lexem
  end

################### SYNTAX ANALYSE ####################################

def parser(lexan)
  if lexan.first[:lexem_type]=='keyword' && lexan.first[:lexema]=='program' && lexan.last[:lexem_type]=='keyword'&&lexan.last[:lexema]=='end'
    return parser_name(lexan)
  elsif lexan.first[:lexem_type]!='keyword' && lexan.last[:lexem_type]=='keyword'&&lexan.last[:lexema]=='end'
    return t('syntax.start.fail_first')
  elsif lexan.first[:lexem_type]=='keyword' && lexan.first[:lexema]=='program'&& lexan.last[:lexem_type]!='keyword'
    return t('syntax.start.fail_last')
  elsif lexan.first[:lexem_type]=='keyword' && lexan.first[:lexema]!='program' && lexan.last[:lexem_type]=='keyword'&&lexan.last[:lexema]=='end'
    return t('syntax.start.fail_first')
  else lexan.first[:lexem_type]=='keyword' && lexan.first[:lexema]=='program' && lexan.last[:lexem_type]=='keyword'&&lexan.last[:lexema]!='end'
    return t('syntax.start.fail_last')
  end
end

def parser_name(lexan)
  lexan=lexan.drop(1)
  program_name=lexan.first[:lexema]
  if lexan.first[:lexem_type]=='identificator'
    parse_statement_list(lexan)
  else
    t('syntax.start.success')+t('syntax.name.fail')
  end
end
def table_ident_create(lexan)
  table_identificators=Array.new;
  string= Array.new
  lexan=lexan.drop(1)
  lexan.pop
  i=1
  l=lexan.last[:num_line]
  while i<l do
    string=lexan.select {|v| v[:num_line]==i}
    string=string.drop(1) if string.first[:lexema]==';'
    if string.first[:lexem_type]=='identificator' && string.length==3 && (string.last[:lexem_type]=='integer'||string.last[:lexem_type]=='real')
      string.first[:assign_value]=string.last[:lexema]
      table_identificators.push(string.first)
    end
    i+=1
  end
  return table_identificators
end
def parse_statement_list(lexan)
  string= Array.new
  lexan=lexan.drop(1)
  lexan.pop
  i=1
  l=lexan.last[:num_line]
  while i<l do
    string=lexan.select {|v| v[:num_line]==i}
    string=string.drop(1) if string.first[:lexema]==';'
    if string.first[:lexem_type]=='identificator'
      result = parser_assign(string)
      poliz(string)
      calc_poliz(string.drop(1), lexan)
    elsif string.first[:lexema]=='if'
      result = parser_if(string)
    elsif string.first[:lexema]=='for'
      result = parser_expression_for(string)
    else
      return t('syntax.statemen_list.fail')+"#{i}"
    end
    i+=1
  end
  return result+t('syntax.statemen_list.success')
end

def parser_assign(string)
  string=string.drop(1)

  if string.first!=nil && string.first[:lexem_type]=='assign' && (string[1][:lexema]=='(' || string[1][:lexem_type]=='integer'||string[1][:lexem_type]=='real'||string[1][:lexem_type]=='identificator')
    return parser_expression(string)
  else
    return t('syntax.assign.fail')+"#{string.first[:num_line]}"
  end
end

def parser_expression(string)
  string=string.drop(1)
  string_term=Array.new
  count_begin=0
  count_end=0
  string.each do |item|
    count_begin+=1 if item[:lexema]=='('
    count_end+=1 if item[:lexema]==')'
  end
  return t('syntax.expression.fail_bracket')+"#{string.first[:num_line]}" if count_begin != count_end
  i=0
  l=string.length
  while i<l do
    if string[i][:lexem_type]=='log_op'
      return t('syntax.expression.fail_sign')+"#{string[i][:num_line]}"
    elsif string[i][:lexem_type]!='add_op'
      string_term.push(string[i])
    else
      parser_term(string_term)
      string_term=Array.new
    end
      i+=1
  end
  t('syntax.expression.success')
end


def parser_term(string)
  string.each do |item|
    if item[:lexem_type]!='math_op'
      next if parser_factor(item)==true
    else
      return t('syntax.expression.fail')+"#{item[:num_line]}"
    end
  end
end

def parser_factor(lexema)
  true if lexema[:lexem_type]=='identificator'
  true if lexema[:lexem_type]=='real'
  true if lexema[:lexem_type]=='integer'
  true if lexema[:lexem_type]=='order_opp'
end

def parser_if(string)
  string=string.drop(1)
  l=string.length
  i=0
  return t('syntax.if.fail_label')+"#{string.last[:num_line]}" unless string.last[:lexem_type]=='integer' && string[l-2][:lexema]=='goto'
  while i<=l-3 do
    result = parser_expression_if(string[i])
    return t('syntax.if.fail')+"#{string[i][:num_line]}" if result!=true
    i+=1
  end
    return t('syntax.if.success')
end

def parser_expression_if(lexema)
  return true if lexema[:lexem_type]=='identificator'
  return true if lexema[:lexem_type]=='log_op'
  return true if lexema[:lexem_type]=='boolean'
  return true if lexema[:lexem_type]=='integer'
  return true if lexema[:lexem_type]=='real'
end

def parser_expression_for(string)
  i=7
  l=string.length
  string_for=Array.new
  return t('syntax.for.fail_brecket')+"#{string.first[:num_line]}" if string.last[:lexema]!='end'
  return t('syntax.for.fail_todo')+"#{string.first[:num_line]}" if string[1][:lexem_type]!='identificator'||string[2][:lexema]!='='||
  string[3][:lexem_type]!='integer'||string[4][:lexema]!='to'||string[5][:lexem_type]!='integer'||string[6][:lexema]!='do'
  return t('syntax.for.fail_instruction')+"#{string.first[:num_line]}" if l==8
  while i<l-1 do
    string_for.push(string[i])
    i+=1
  end
  parser_assign(string_for) if string_for!=nil
end
####################### RPN ##################
  def poliz(string)
    string_poliz = string.drop(2)
    expression_bracket=Array.new
    exp_main = Array.new
    k=false
    string_poliz.each do |item|
      k=true if item[:lexema]=='('
      k=false if item[:lexema]==')'
      expression_bracket.push(item) if k==true
      exp_main.push(item) if k==false
    end
    expression_bracket=expression_bracket.drop(1)
    order=poliz_exp(expression_bracket,0)
    return poliz_exp(exp_main, order)
  end


  def poliz_exp(string_poliz, string_order)
    stack=Array.new
    rpn= Array.new
    i=0
    j=0
    while i<string_poliz.length do
      if string_poliz[i][:lexema]==')'
        string_order.each do |bracket_exp|
          rpn.push(bracket_exp)
        end
      elsif string_poliz[i][:lexem_type]=='identificator'||string_poliz[i][:lexem_type]=='integer'||string_poliz[i][:lexem_type]=='real'
        rpn.push(string_poliz[i])
      elsif string_poliz[i][:lexem_type]=='math_op'
        if j!=0 && stack[j-1]!=nil && stack[j-1][:lexem_type]=='math_op'
          rpn.push(stack[j-1])
          stack.pop
          stack.push(string_poliz[i])
        else
          stack.push(string_poliz[i])
          j+=1
        end
      elsif string_poliz[i][:lexem_type]=='add_op'
        if j!=0 && stack[j-1]!=nil && stack[j-1][:lexem_type]=='math_op'
          rpn.push(stack[j-1])
          stack.pop
          stack.push(string_poliz[i])
          j+=1
        else
          stack.push(string_poliz[i])
          j+=1
        end
      end
      i+=1
    end
    while stack.length!=0 do
      rpn.push(stack.last)
      stack.pop
    end
    return rpn
  end
  ######################## CALCULATING RPN ################################
  def calc_poliz(rpn,lexan)
    tabel_identificators=table_ident_create(lexan)
    stack=Array.new
    rpn.each do |item|
      if item[:lexem_type]=="identificator"
        tabel_identificators.each do |ident_value|
          stack.push(ident_value[:assign_value].to_f)if ident_value[:lexema]==item[:lexema]
        end
      elsif item[:lexem_type]=="integer"||item[:lexem_type]=="real"
        stack.push(item[:lexema].to_f)
      elsif item[:lexema]=="+"
        right_operand=stack.pop
        left_operand=stack.pop
        if right_operand!=nil && left_operand !=nil
          stack.push(right_operand+left_operand)
        else
          return t('poliz.fail_identificator')+"#{item[:num_line]}"
        end
      elsif item[:lexema]=="*"
        right_operand=stack.pop
        left_operand=stack.pop
        if right_operand!=nil && left_operand !=nil
          stack.push(right_operand*left_operand)
        else
          return t('poliz.fail_identificator')+"#{item[:num_line]}"
        end
      elsif item[:lexema]=="/"
        right_operand=stack.pop
        left_operand=stack.pop
        return t('syntax.assign.fail_0')+"#{item[:num_line]}" if right_operand==0
        if right_operand!=nil && left_operand !=nil
          stack.push(left_operand/right_operand )
        else
          return t('poliz.fail_identificator')+"#{item[:num_line]}"
        end
      elsif item[:lexema]=="-"
        right_operand=stack.pop
        left_operand=stack.pop
        if right_operand!=nil && left_operand !=nil
          stack.push(left_operand-right_operand)
        else
          return t('poliz.fail_identificator')+"#{item[:num_line]}"
        end
      elsif item[:lexema]=="^"
        right_operand=stack.pop
        left_operand=stack.pop
        if right_operand!=nil && left_operand !=nil
          stack.push(left_operand**right_operand)
        else
          return t('poliz.fail_identificator')+"#{item[:num_line]}"
        end
      else return t('poliz.fail')
      end
    end
    return stack.pop
  end
end
