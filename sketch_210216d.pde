BufferedReader reader;

int x;
int y;

int old_x=-1;
int old_y=-1;

int rx;
int ry;

int old_rx=-1;
int old_ry=-1;

int limit=100;
int[][] trajectory = new int[limit][2];

//Listes des transitions pour chaque figure
int[] states = new int[limit+1];

//Pour les probabilités
float[][] traProbR = new float[8][8];
float[] iniProbR = new float[8];
float[][] traProbC = new float[8][8];
float[] iniProbC = new float[8];

int step;

int i=0;

void drawgrid(){
  background(255);
  fill(0);
  for(int i=0; i<width; i+=step){
    line(i, 0, i, height);
  }
  for(int j=0; j<height; j+=step){
    line(0, j, width, j);
  }
}

void setup(){
  size(750, 750);
  step = width/50;  
  background(255);
  
  loadFiles();
  
}

void draw(){
  if(mousePressed){
    if(old_x == -1){
      old_x = mouseX;
      old_y = mouseY;
      old_rx = round(float(old_x)/step);
      old_ry = round(float(old_y)/step);
    }
    else{
      x = mouseX;
      y = mouseY;
      fill(0);
      line(old_x, old_y, x, y);
      old_x = x;
      old_y = y;
      
      rx = round(float(x)/step);
      ry = round(float(y)/step);
      if(abs(rx*step-x) + abs(ry*step-y) <= 0.7*step){
        if(i<limit-1){
          if(trajectory[i][0] != rx || trajectory[i][1] != ry){
            fill(255, 0, 0);
            ellipse(rx*step, ry*step, 10, 10);
            trajectory[i+1][0] = rx;
            trajectory[i+1][1] = ry;
            i++;
          }
        }
      }
    }
  }

}

void mousePressed(){
    drawgrid();
    
}

void mouseReleased(){
    
  getStates(); 
  String shape = findShape();
  print("C'est un "+shape);
  
  drawPerfShape(shape);
  
  i=0;
}

void loadFiles(){

  String[] content = loadStrings("proba_circ.csv");
  int count = 0;
  
  for(String e :content){ //Pour chaque ligne du document csv
    String[] a = split(e,",");
    if(count<8){
      for(int j=0;j<8;j++){ //Pour chaque caractère numérique de cette ligne
        traProbC[count][j] = float(a[j]);
      }
    }else if(count >=8 && a.length>2){ //Il y a peut-être une ligne vide à prendre en compte
      for(int j=0;j<8;j++){ //Pour chaque caractère numérique de cette ligne
        iniProbC[j] = float(a[j]);
      }
    }
  count ++;
  }
  
  content = loadStrings("proba_rect.csv");
  count = 0;
  
  for(String e :content){ //Pour chaque ligne du document csv
    String[] a = split(e,",");
    if(count<8){
      for(int j=0;j<8;j++){ //Pour chaque caractère numérique de cette ligne
        traProbR[count][j] = float(a[j]);
      }
    }else if(count >=8 && a.length>2){ //Il y a peut-être une ligne vide à prendre en compte
      for(int j=0;j<8;j++){ //Pour chaque caractère numérique de cette ligne
        iniProbR[j] = float(a[j]);
      }
    
    }
   count ++;
  }

}


void getStates(){

   for(int j=0 ;j<i;j++){
     if(trajectory[j+1][0]-trajectory[j][0]>0 && trajectory[j+1][1]-trajectory[j][1]==0){
       states[j]=0;
     }else if(trajectory[j+1][0]-trajectory[j][0]>0 && trajectory[j+1][1]-trajectory[j][1]>0){
       states[j]=7;
     }else if(trajectory[j+1][0]-trajectory[j][0]==0 && trajectory[j+1][1]-trajectory[j][1]>0){
       states[j]=6;
     }else if(trajectory[j+1][0]-trajectory[j][0]<0 && trajectory[j+1][1]-trajectory[j][1]>0){
       states[j]=5;
     }else if(trajectory[j+1][0]-trajectory[j][0]<0 && trajectory[j+1][1]-trajectory[j][1]==0){
       states[j]=4;
     }else if(trajectory[j+1][0]-trajectory[j][0]<0 && trajectory[j+1][1]-trajectory[j][1]<0){
       states[j]=3;
     }else if(trajectory[j+1][0]-trajectory[j][0]==0 && trajectory[j+1][1]-trajectory[j][1]<0){
       states[j]=2;
     }else if(trajectory[j+1][0]-trajectory[j][0]>0 && trajectory[j+1][1]-trajectory[j][1]<0){
       states[j]=1;
     }
   }

}

String findShape(){
  float pCirc,pRect;
  
  //P(X0=x0)
  pCirc = iniProbC[states[1]];
  pRect = iniProbR[states[1]];
  
  //Produit(P(Xt+1=xt+1|Xt=xt))
  for(int j=2;j<states.length-1;j++){
    pCirc *= traProbC[states[j]][states[j+1]];
    pRect *= traProbR[states[j]][states[j+1]];
  }
  
  if(pCirc>pRect){
    return "cercle";
  }else{
    return "rectangle";
  }
}


void drawPerfShape(String shape){ //BONUS

  float centerX =0 ,centerY =0;
  int minX=trajectory[2][0],minY=trajectory[2][1],maxX=trajectory[2][0],maxY=trajectory[2][1];
  float per =0;
  
  for(int j=1;j<i;j++){
    centerX += trajectory[j][0];
    centerY += trajectory[j][1];
    if(shape=="rectangle"){ //On cherche les points plus haut, plus bas, plus à droite et plus à gauche -- alternative : chercher les coins dans les transitions
      if(trajectory[j][0]<minX){
        print("I'm in"+minX+" eeee"+trajectory[j][0]);
        minX = trajectory[j][0];
      }else if(trajectory[j][0]>maxX){
        maxX = trajectory[j][0];
      }else if(trajectory[j][1]<minY){
        minY = trajectory[j][1];
      }else if(trajectory[j][1]>maxY){
        maxY = trajectory[j][1];
      }
    }else if (j<i-1){ //Approximer le rayon en faisant per = 2 pi r  <=> per/2pi = r -- distance euclidienne 
      per += sqrt(pow(trajectory[j][0]-trajectory[j+1][0],2)+pow(trajectory[j][1]-trajectory[j+1][1],2));    
    }
  }
  
  per = per/3.14; //On divise que par pi, parce que deux pi fait des cercles trop petits -- aucune idée de pourquoi 
  
  centerX /= i;
  centerY/= i;
  
  background(255);
  fill(0);  
  if(shape=="rectangle"){
    rect(minX*step,minY*step,abs(maxX-minX)*step,abs(maxY-minY)*step);
  }else{
    circle(centerX*step,centerY*step,per*step);
  }
  

}
