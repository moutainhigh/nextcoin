/**
 * POSCMS 通用js文件
 * 成都天睿信息技术有限公司版权所有
 * */
function d_tips(name,status,code){var obj=$("#dr_"+name+"_tips");var value=obj.html();if(!value){obj.html("")}if(status){if(code){dr_tips(code,3,1)}}else{$("#dr_"+name).focus();if(code){dr_tips(code)}}top.$(".page-loading").remove()}function check_title(t){var val=$("#dr_title").val();var mod=$("#dr_module").val();var id=$("#dr_id").val();$.get(memberpath+"index.php?s=member&c=api&m=checktitle&title="+val+"&module="+mod+"&id="+id+"&rand="+Math.random(),function(data){if(data){if(t=="1"){dr_tips(data)}else{$("#dr_title_tips").html(data)}}else{if(t=="1"){dr_tips('',3,1)}else{$("#dr_title_tips").html("")}}})}function get_keywords(to){var title=$("#dr_title").val();if($("#dr_"+to).val()){return false}$.get(memberpath+"index.php?s=member&c=api&m=getkeywords&title="+title+"&rand="+Math.random(),function(data){$("#dr_"+to).val(data);$("#dr_"+to).tagsinput('add',data)})}function d_topinyin(name,from,letter){var val=$("#dr_"+from).val();if($("#dr_"+name).val()){return false}$.get(memberpath+"index.php?s=member&c=api&m=pinyin&name="+val+"&rand="+Math.random(),function(data){$("#dr_"+name).val(data);if(letter){$("#dr_letter").val(data.substr(0,1))}})}function d_required(name){if($("#dr_"+name).val()==""){d_tips(name,false);return true}else{d_tips(name,true);return false}}function d_isemail(name){var val=$("#dr_"+name).val();var reg=/^[-_A-Za-z0-9]+@([_A-Za-z0-9]+\.)+[A-Za-z0-9]{2,3}$/;if(reg.test(val)){d_tips(name,true);return false}else{d_tips(name,false);return true}}function d_isurl(name){var val=$("#dr_"+name).val();var reg=/http(s)?:\/\/([\w-]+\.)+[\w-]+(\/[\w- .\/?%&=]*)?/;var Exp=new RegExp(reg);if(Exp.test(val)==true){d_tips(name,true);return false}else{d_tips(name,false);return true}}function d_isdomain(name){var val=$("#dr_"+name).val();if(val.indexOf("/")>0){d_tips(name,false);return true}else{d_tips(name,true);return false}};