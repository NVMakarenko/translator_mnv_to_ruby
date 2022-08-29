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
      'keyword' => ['program', 'end', 'for', 'to', 'do', 'if', 'goto', 'endfor', 'label'],
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
    array_lexem.push(hash_token)
    hash_token=Hash.new
  end
  return array_lexem
  end

################### SYNTAX ANALYSE ####################################

def parser(lexan)
  if lexan.first[:lexem_type]=='keyword' && lexan.first[:lexema]=='program' && lexan.last[:lexem_type]=='keyword'&&lexan.last[:lexema]=='end'
    parser_name(lexan)
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
    return parse_statement_list(lexan)
  else
    t('syntax.start.success')+t('syntax.name.fail')
  end
end

def parse_statement_list(lexan)
  string= Array.new
  lexan=lexan.drop(1)
  lexan.pop
  return t('syntax.statemen_list.fail') + "1" if lexan==[]
  i=1
  l=lexan.last[:num_line]
  count_for=0
  count_endfor=0
  count_label=0
  table_labels=table_label_create(lexan)
  while i<l do
    string=lexan.select {|v| v[:num_line]==i}
    string=string.drop(1) if string.first[:lexema]==';'
    if string.first[:lexem_type]=='identificator' && string.length>1
      result = parser_assign(string)
      return t('syntax.assign.fail')+"#{string.first[:num_line]}" if result==false
    elsif string.first[:lexema]=='if'
      result = parser_if(string, table_labels)
      return t('syntax.if.fail_label')+"#{string.last[:num_line]}" if result==false
    elsif string.first[:lexema]=='for'
      count_for +=1
      result = parser_for(string)
      return t('syntax.for.fail_brecket')+"#{string.first[:num_line]}" if result==false
    elsif string.first[:lexema]=='endfor'
      count_endfor+=1
    elsif string.first[:lexem_type]=='identificator' && string.length==1
      count_label
    else
      return t('syntax.statemen_list.fail')+"#{i}"
    end
    i+=1
  end
  return t('syntax.for.fail_brecket')+"#{string.first[:num_line]}" if count_for!=count_endfor
  return result
end

def parser_assign(string)
  count_start=0
  count_finish=0
  return false unless string[1]!=nil && string[2]!=nil && string[1][:lexem_type]=='assign' && (string[2][:lexema]=='(' || string[2][:lexem_type]=='integer'||string[2][:lexem_type]=='real'||string[2][:lexem_type]=='identificator')
  string.each do |item|
    count_start+=1 if item[:lexema]=='('
    count_finish+=1 if item[:lexema]==')'
    return false if item[:lexem_type]=='keyword'
  end
  return false if count_start != count_finish
  return t('syntax.statemen_list.success')
end

def parser_if(string, table_labels)
  l=string.length
  expression_if=get_expression_if(string.drop(1))
  count_log=0
  return false unless string.last[:lexem_type]=='identificator' && string[l-2][:lexema]=='goto'
  return false if expression_if.length<3
  return false unless expression_if.first[:lexema]!='('||expression_if.first[:lexem_type]!='integer'||expression_if.first[:lexem_type]!='real'||expression_if.first[:lexem_type]!='identificator'
  return false unless expression_if.last[:lexema]!=')'||expression_if.last[:lexem_type]!='integer'||expression_if.last[:lexem_type]!='real'||expression_if.last[:lexem_type]!='identificator'
  expression_if.each do |operand|
    count_log+=1 if operand[:lexem_type]=='log_op'
    return false if operand[:lexem_type]=='keyword'||operand[:lexem_type]=='new_line'
  end
  return false if count_log!=1
  table_labels.each do |label|
    return t('syntax.statemen_list.success') if label[:lexema]==string.last[:lexema]
  end
  return false
end

def parser_for(string)
  return t('syntax.for.fail_instruction')+"#{string.first[:num_line]}" if string[1][:lexem_type]!='identificator'||string[2][:lexema]!='='||string.last[:lexema]!='do'
  return t('syntax.statemen_list.success')
end

def parse_statement(lexan)
  table_labels=table_label_create(lexan)
  lexan=lexan.drop(2)
  lexan.pop(1)
  table_identification=table_ident_create(lexan)
  i=1
  l=lexan.last[:num_line]
  count_for=0
  count_endfor=0
  while i<l do
    string=lexan.select {|v| v[:num_line]==i}
    string=string.drop(1) if string.first[:lexema]==';'
    if string.first[:lexem_type]=='identificator'&&string.length>3
      rpn=parser_expression(string.drop(2))
      string.first[:assign_value]=calc_poliz(rpn,table_identification)
      table_identification.push(string.first)
    elsif string.first[:lexema]=='if'
      result = get_if(string, table_identification)
      if result==true
        table_labels.each do |label|
          i=label[:num_line] if label[:lexema]==string.last[:lexema]
        end
      end
    elsif string.first[:lexema]=='for'
      count_for+=1
      k=string.first[:num_line]
      identif=string[1][:lexema]
      repeat_times=get_for(string, table_identification)
    elsif string.first[:lexema]=='endfor'
      count_endfor+=1
      if count_for==count_endfor
        repeat_times.times do
          table_identification.each do |item|
            item[:assign_value]+=1 if item[:lexema]==identif
          end
          i=k
        end
      end
    end
    i+=1
  end
  return table_identification.uniq
end

def table_ident_create(lexan)
  table_identificators=Array.new;
  string= Array.new
  for_string=Hash.new
  i=1
  l=lexan.last[:num_line]
  while i<l do
    string=lexan.select {|v| v[:num_line]==i}
    string=string.drop(1) if string.first[:lexema]==';'
    if string.first[:lexem_type]=='identificator' && string.length==3 && (string.last[:lexem_type]=='integer'||string.last[:lexem_type]=='real')
      string.first[:assign_value]=string.last[:lexema].to_f
      table_identificators.push(string.first)
    elsif string.first[:lexema]=='for'
      for_string[:num_line]= string.first[:num_line]
      for_string[:lexem_type]='identificator'
      for_string[:lexema]=string[1][:lexema]
      for_string[:assign_value]=calc_poliz(get_expression_from(string.drop(3)), table_identificators)
      table_identificators.push(for_string)
      for_string=Hash.new
    end
    i+=1
  end
  return table_identificators
end

def table_label_create(lexan)
  i=1
  l=lexan.last[:num_line]
  table_labels=Array.new
  while i<l do
    string=lexan.select {|v| v[:num_line]==i}
    string=string.drop(1) if string.first[:lexema]==';'
    table_labels.push(string) if string!=nil && string.first[:lexem_type]=='identificator' && string.length==1
    i+=1
  end
  table_labels.flatten!
  return table_labels
end

def parser_expression(string)
  result=Array.new
  string_term=Array.new
  i=0
  l=string.length
  count_start=0
  count_finish=0
  while i<l do
    if string[i][:lexema]=='('
      count_start+=1
      begin
        string_term.push(string[i])
        i+=1
        count_start+=1 if string[i][:lexema]=='('
        count_finish+=1 if string[i][:lexema]==')'
      end while count_start!=count_finish
      string_term.push(string[i])
      i+=1
      while i<l do
        string_term.push(string[i]) if string[i][:lexem_type]!='add_op'
        if string[i][:lexem_type]=='add_op'
          result.push(parser_term(string_term))
          sign=(string[i]) if string[i]!=nil
          string_term=Array.new
        end
        i+=1
      end
    else
      string_term.push(string[i]) if string[i][:lexem_type]!='add_op'
      if string[i][:lexem_type]=='add_op'
        result.push(parser_term(string_term))
        sign=(string[i]) if string[i]!=nil
        string_term=Array.new
      end
    end
    i+=1
  end
  result.push(parser_term(string_term))
  result.push(sign)if sign!=nil
  result.flatten!

  return result
end

def parser_term(string)
  result = Array.new
  string_factor=Array.new
  i=0
  l=string.length
  count_start=0
  count_finish=0
  while i<l do
    if string[i][:lexema]=='('
      count_start+=1
      begin
        string_factor.push(string[i])
        i+=1
        count_start+=1 if string[i][:lexema]=='('
        count_finish+=1 if string[i][:lexema]==')'
      end while count_start!=count_finish
      string_factor.push(string[i])
      i+=1
      while i<l do
        string_factor.push(string[i]) if string[i][:lexem_type]!='math_op'
        if string[i][:lexem_type]=='math_op'
          result.push(parser_factor(string_factor))
          sign=(string[i]) if string[i]!=nil
          string_factor=Array.new
        end
        i+=1
      end
    else
      string_factor.push(string[i]) if string[i][:lexem_type]!='math_op'
      if string[i][:lexem_type]=='math_op'
        result.push(parser_factor(string_factor))
        sign=(string[i]) if string[i]!=nil
        string_factor=Array.new
      end
    end
    i+=1
  end
  result.push(parser_factor(string_factor))
  result.push(sign) if sign!=nil
  return result
end

def parser_factor(string)
  return string.first if string.length==1 && (string.first[:lexem_type]=='identificator'||string.first[:lexem_type]=='real'||string.first[:lexem_type]=='integer')
  if string.length>1
    string=string.drop(1)
    string.pop
    parser_expression(string)
  end
end

def calc_poliz(rpn,table_identificators)
  stack=Array.new
  rpn.each do |item|
    if item[:lexem_type]=="identificator"
      table_identificators.each do |ident_value|
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

def get_if(string, table_identification)
  expression_if=get_expression_if(string.drop(1))
  rpn_left_operand=parser_expression(get_left_if_operand(expression_if))
  left_operand=calc_poliz(rpn_left_operand, table_identification)
  sign=expression_if.drop(get_left_if_operand(expression_if).length).first
  rpn_right_operand=parser_expression(expression_if.drop(get_left_if_operand(expression_if).length+1))
  right_operand=calc_poliz(rpn_right_operand, table_identification)
  return calc_if(left_operand, right_operand, sign) if left_operand!=nil&&right_operand!=nil
end
  def get_expression_if(string)
    expression_if=Array.new
    string.each do |operand|
      break if operand[:lexema]=='goto'
      expression_if.push(operand)
    end
    return expression_if
  end
  def get_left_if_operand(string)
    left_operand=Array.new
    string.each do |operand|
      break if operand[:lexem_type]=='log_op'
      left_operand.push(operand)
    end
    return left_operand
  end
  def calc_if(left_operand, right_operand, sign)
    case sign[:lexema]
    when ">"
      result = left_operand>right_operand
    when "<"
      result = left_operand>right_operand
    when ">="
      result = left_operand>=right_operand
    when "<="
      result = left_operand<=right_operand
    when "="
      result = left_operand==right_operand
    end
  return result
  end
def get_for(string, table_identification)
  from_operand = calc_poliz(get_expression_from(string.drop(3)), table_identification)
  to_operand = calc_poliz(get_expression_to(string.drop(3)), table_identification)
  return t('syntax.for.fail_todo') if from_operand>to_operand
  return (to_operand-from_operand).to_i
end

  def get_expression_from(string)
    expression_for=Array.new
    string.each do |operand|
      break if operand[:lexema]=='to'
      expression_for.push(operand)
    end
    rpn_expression_for=parser_expression(expression_for)
    return rpn_expression_for
  end
  def get_expression_to(string)
    helper=false
    expression_to=Array.new
    string.each do |operand|
      helper=true if operand[:lexema]=='to'
      break if operand[:lexema]=='do'
      expression_to.push(operand) if helper==true
    end
    helper=false
    rpn_expression_to=parser_expression(expression_to.drop(1))
    return rpn_expression_to
  end
end
